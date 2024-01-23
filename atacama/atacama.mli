open Riot

module Connection : sig
  type t

  val send : t -> Bytestring.t -> (unit, [> `Closed ]) IO.io_result

  (*
  val send_file :
    t ->
    ?off:int ->
    len:int ->
    [ `r ] File.file ->
    (int, [> `Closed ]) IO.io_result
    *)

  val receive :
    ?limit:int ->
    ?read_size:int ->
    t ->
    (Bytestring.t, [> `Closed ]) IO.io_result

  val negotiated_protocol : t -> string option
  val close : t -> unit
  val peer : t -> Net.Addr.stream_addr
  val connected_at : t -> Ptime.t
  val accepted_at : t -> Ptime.t
end

(** An Atacama Handler determines how every connection handled by Atacama will
    behave. It defines a number of hooks for handling the state of the connection:

    * `handle_close` – for when a connection is about to be closed

    * `handle_connection` - to prepare the state of a connection right after
      it started.

    * `handle_data` – to deal with data packets as they come. It is worth
      noting that Atacama does not determine how much to buffer, or how to
      read, and this is defined in the Transport module used.

    * `handle_error` - to receive and handle any connection errors.
*)
module rec Handler : sig
  type t =
    | H : {
        handler :
          (module Handler.Intf
             with type state = 'new_state
              and type error = 'error);
        state : 'new_state;
      }
        -> t

  type ('state, 'error) handler_result =
    | Ok
    | Continue of 'state
    | Continue_with_timeout of 'state * Timeout.t
    | Close of 'state
    | Error of 'state * 'error
    | Switch of t

  (** The interface of an Atacama Handler. It is worth noting that you don't
      have to explicitly implement this interface, which allows your modules to
      include _more_ than is specified here.

   *)
  module type Intf = sig
    type state
    type error

    val pp_err : Format.formatter -> error -> unit
    val handle_close : Connection.t -> state -> unit

    val handle_connection :
      Connection.t -> state -> (state, error) handler_result

    val handle_data :
      Bytestring.t -> Connection.t -> state -> (state, error) handler_result

    val handle_error :
      error -> Connection.t -> state -> (state, error) handler_result

    val handle_shutdown : Connection.t -> state -> (state, error) handler_result
    val handle_timeout : Connection.t -> state -> (state, error) handler_result

    val handle_message :
      Message.t -> Connection.t -> state -> (state, error) handler_result
  end

  (** Default handler methods. Useful for bootstrapping new handlers incrementally.

      You can use this module by just including it inside your new handle module:

      ```ocaml
      module My_handler = struct
        include Atacama.Handler.Default

        (* .. define overrides .. *)
      end
      ```
  *)
  module Default : sig
    val handle_close : Connection.t -> 'state -> unit

    val handle_connection :
      Connection.t -> 'state -> ('state, 'error) handler_result

    val handle_data :
      Bytestring.t -> Connection.t -> 'state -> ('state, 'error) handler_result

    val handle_error :
      'error -> Connection.t -> 'state -> ('state, 'error) handler_result

    val handle_shutdown :
      Connection.t -> 'state -> ('state, 'error) handler_result

    val handle_timeout :
      Connection.t -> 'state -> ('state, 'error) handler_result

    val handle_message :
      Message.t -> Connection.t -> 'state -> ('state, 'error) handler_result
  end
end

module Transport : sig
  type t

  module Tcp : sig
    type config = { receive_timeout : int64; send_timeout : int64 }
  end

  module Ssl : sig
    type config = { tcp : Tcp.config; tls : Tls.Config.server }
  end

  val tcp : ?config:Tcp.config -> unit -> t
  val ssl : config:Ssl.config -> unit -> t
end

val start_link :
  port:int ->
  ?acceptors:int ->
  ?max_connections:int ->
  ?buffer_size:int ->
  ?transport:Transport.t ->
  (module Handler.Intf with type state = 'state and type error = 'err) ->
  'state ->
  (Pid.t, [> `Supervisor_error ]) result
(** Start an Atacama server.

    The default `acceptors` is 100.

    The default `transport is clear TCP sockets.

*)

module Telemetry : sig
  type Telemetry.event +=
    | Accepted_connection of { client_addr : Net.Addr.stream_addr }
    | Connection_started
    | Listening of { socket : Net.Socket.listen_socket }
end
