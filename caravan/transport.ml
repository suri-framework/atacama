open Riot

module type Intf = sig
  val listen :
    ?opts:Net.Socket.listen_opts ->
    port:int ->
    unit ->
    (Net.listen_socket, [> `System_limit ]) Net.Socket.result

  val connect :
    Net.Addr.stream_addr -> (Net.stream_socket, [> `Closed ]) Net.Socket.result

  val accept :
    ?timeout:Net.Socket.timeout ->
    Net.listen_socket ->
    ( Net.stream_socket * Net.Addr.stream_addr,
      [> `Closed | `Timeout | `System_limit ] )
    Net.Socket.result

  val close : _ Net.socket -> unit

  val controlling_process :
    _ Net.socket ->
    new_owner:Pid.t ->
    (unit, [> `Closed | `Not_owner ]) Net.Socket.result

  val receive :
    ?timeout:Net.Socket.timeout ->
    len:int ->
    Net.stream_socket ->
    (Bigstringaf.t, [> `Closed | `Timeout ]) Net.Socket.result

  val send :
    Bigstringaf.t -> Net.stream_socket -> (int, [> `Closed ]) Net.Socket.result

  val handshake : Net.stream_socket -> (unit, [> `Closed ]) Net.Socket.result
end

module Tcp : Intf = struct
  let listen = Net.Socket.listen
  let connect = Net.Socket.connect
  let accept = Net.Socket.accept
  let close = Net.Socket.close
  let controlling_process = Net.Socket.controlling_process
  let receive = Net.Socket.receive
  let send = Net.Socket.send
  let handshake _socket = Ok ()
end
