open Riot

module type Intf = sig
  val listen :
    ?opts:Riot.Socket.listen_opts ->
    port:int ->
    unit ->
    (Net.listen_socket, [> `System_limit ]) Riot.Socket.result

  val connect :
    Net.Addr.stream_addr -> (Net.stream_socket, [> `Closed ]) Riot.Socket.result

  val accept :
    ?timeout:Riot.Socket.timeout ->
    Net.listen_socket ->
    ( Net.stream_socket * Net.Addr.stream_addr,
      [> `Closed | `Timeout | `System_limit ] )
    Riot.Socket.result

  val close : _ Net.socket -> unit

  val controlling_process :
    _ Net.socket ->
    new_owner:Pid.t ->
    (unit, [> `Closed | `Not_owner ]) Riot.Socket.result

  val receive :
    ?timeout:Riot.Socket.timeout ->
    len:int ->
    Net.stream_socket ->
    (Bigstringaf.t, [> `Closed | `Timeout ]) Riot.Socket.result

  val send :
    Bigstringaf.t -> Net.stream_socket -> (int, [> `Closed ]) Riot.Socket.result

  val handshake : Net.stream_socket -> (unit, [> `Closed ]) Riot.Socket.result
end

module Tcp : Intf = struct
  let listen = Riot.Socket.listen
  let connect = Riot.Socket.connect
  let accept = Riot.Socket.accept
  let close = Riot.Socket.close
  let controlling_process = Riot.Socket.controlling_process
  let receive = Riot.Socket.receive
  let send = Riot.Socket.send
  let handshake _socket = Ok ()
end
