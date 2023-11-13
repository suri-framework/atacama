open Riot

type t = {
  socket : Net.stream_socket;
  transport : (module Transport.Intf);
  buffer_size : int;
}

let make socket transport buffer_size = { socket; transport; buffer_size }

let handshake ({ socket; transport = (module T : Transport.Intf); _ } as t) =
  match T.handshake socket with Ok () -> Ok t | Error reason -> Error reason

let receive
    { socket; transport = (module T : Transport.Intf); buffer_size = len }
    ~timeout =
  T.receive ~timeout ~len socket

let send { socket; transport = (module T : Transport.Intf); _ } data =
  T.send data socket
