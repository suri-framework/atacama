open Riot

let ( let* ) = Result.bind

module type Intf = sig
  type config

  val handshake :
    config:config ->
    socket:Net.Socket.stream_socket ->
    buffer_size:int ->
    ( Connection.t,
      [> `Closed | `Inactive_tls_engine | `No_session_data ] )
    IO.result
end

type t =
  | T : {
      transport : (module Intf with type config = 'config);
      config : 'config;
    }
      -> t

let handshake (T { transport = (module T); config }) ~socket ~buffer_size =
  T.handshake ~config ~socket ~buffer_size

module Tcp = struct
  type config = { receive_timeout : int64 }

  let default_config = { receive_timeout = 5_000_000L }

  let handshake ~config:_ ~socket ~buffer_size =
    let reader, writer = Net.Socket.(to_reader socket, to_writer socket) in
    let conn = Connection.make ~reader ~writer ~buffer_size ~socket () in
    Ok conn
end

let tcp ?(config = Tcp.default_config) () =
  T { transport = (module Tcp); config }

module Ssl = struct
  type config = Tls.Config.server

  let handshake ~config ~socket ~buffer_size =
    let ssl = SSL.of_server_socket ~config socket in
    let reader, writer = SSL.(to_reader ssl, to_writer ssl) in
    let* protocol = SSL.negotiated_protocol ssl in
    let conn =
      Connection.make ~protocol ~reader ~writer ~buffer_size ~socket ()
    in
    Ok conn
end

let ssl ~config () = T { transport = (module Ssl); config }
