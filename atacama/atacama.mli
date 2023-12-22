open Riot

module Socket : sig
  type t

  val handshake : t -> (t, [> `Closed | `Unix_error of Unix.error ]) result

  val receive :
    t ->
    timeout:Net.Socket.timeout ->
    (Bigstringaf.t, [> `Closed | `Timeout | `Unix_error of Unix.error ]) result

  val send :
    t -> Bigstringaf.t -> (int, [> `Closed | `Unix_error of Unix.error ]) result
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
module Handler : sig
  type ('state, 'error) handler_result =
    | Ok
    | Continue of 'state
    | Continue_with_timeout of 'state * Net.Socket.timeout
    | Close of 'state
    | Error of 'state * 'error

  (** The interface of an Atacama Handler. It is worth noting that you don't
      have to explicitly implement this interface, which allows your modules to
      include _more_ than is specified here.

   *)
  module type Intf = sig
    type state

    val handle_close : Socket.t -> state -> unit
    val handle_connection : Socket.t -> state -> (state, 'error) handler_result

    val handle_data :
      Bigstringaf.t -> Socket.t -> state -> (state, 'error) handler_result

    val handle_error :
      'error -> Socket.t -> state -> (state, 'error) handler_result

    val handle_shutdown : Socket.t -> state -> (state, 'error) handler_result
    val handle_timeout : Socket.t -> state -> (state, 'error) handler_result
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
    val handle_close : Socket.t -> 'state -> unit

    val handle_connection :
      Socket.t -> 'state -> ('state, 'error) handler_result

    val handle_data :
      Bigstringaf.t -> Socket.t -> 'state -> ('state, 'error) handler_result

    val handle_error :
      'error -> Socket.t -> 'state -> ('state, 'error) handler_result

    val handle_shutdown : Socket.t -> 'state -> ('state, 'error) handler_result
    val handle_timeout : Socket.t -> 'state -> ('state, 'error) handler_result
  end

  type 's t = (module Intf with type state = 's)
end

module Transport : sig
  module type Intf = sig
    val listen :
      ?opts:Net.Socket.listen_opts ->
      port:int ->
      unit ->
      ( Net.Socket.listen_socket,
        [> `System_limit | `Unix_error of Unix.error ] )
      result

    val connect :
      Net.Addr.stream_addr ->
      ( Net.Socket.stream_socket,
        [> `Closed | `Unix_error of Unix.error ] )
      result

    val accept :
      ?timeout:Net.Socket.timeout ->
      Net.Socket.listen_socket ->
      ( Net.Socket.stream_socket * Net.Addr.stream_addr,
        [> `Closed | `System_limit | `Timeout | `Unix_error of Unix.error ] )
      result

    val close : 'a Net.Socket.socket -> unit

    val controlling_process :
      'a Net.Socket.socket ->
      new_owner:Pid.t ->
      (unit, [> `Closed | `Not_owner | `Unix_error of Unix.error ]) result

    val receive :
      ?timeout:Net.Socket.timeout ->
      buf:Bigstringaf.t ->
      Net.Socket.stream_socket ->
      (int, [> `Closed | `Timeout | `Unix_error of Unix.error ]) result

    val send :
      data:Bigstringaf.t ->
      Net.Socket.stream_socket ->
      (int, [> `Closed | `Unix_error of Unix.error ]) result

    val handshake :
      Net.Socket.stream_socket ->
      (unit, [> `Closed | `Unix_error of Unix.error ]) result
  end

  module Tcp : Intf
end

val start_link :
  port:int ->
  ?acceptor_count:int ->
  ?buffer_size:int ->
  ?transport_module:(module Transport.Intf) ->
  'ctx Handler.t ->
  'ctx ->
  (Pid.t, [> `Supervisor_error ]) result
(** Start an Atacama server.

    The default `acceptor_count` is 100.

    The default `transport_module` is clear TCP sockets.

*)

module Telemetry : sig
  type Telemetry.event +=
    | Accepted_connection of { client_addr : Net.Addr.stream_addr }
    | Connection_started
    | Listening of { socket : Net.Socket.listen_socket }
end
