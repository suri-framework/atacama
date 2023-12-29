open Riot

let ( let* ) = Result.bind

module type Intf = sig
  val handshake :
    socket:Net.Socket.stream_socket ->
    buffer_size:int ->
    ( Connection.t,
      [> `Closed | `Inactive_tls_engine | `No_session_data ] )
    IO.result
end

module Tcp : Intf = struct
  let handshake ~socket ~buffer_size =
    let reader, writer = Net.Socket.(to_reader socket, to_writer socket) in
    let conn = Connection.make ~reader ~writer ~buffer_size () in
    Ok conn
end

module Ssl : Intf = struct
  let handshake ~socket ~buffer_size =
    let ssl = SSL.of_server_socket socket in
    let reader, writer = SSL.(to_reader ssl, to_writer ssl) in
    let* protocol = SSL.negotiated_protocol ssl in
    let conn = Connection.make ~protocol ~reader ~writer ~buffer_size () in
    Ok conn
end
