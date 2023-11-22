open Riot

type t = {
  socket : Net.Socket.stream_socket;
  transport : (module Transport.Intf);
  buffer_size : int;
}

let pp ppf t = Format.fprintf ppf "Socket<%d>" (Obj.magic t.socket)
let make socket transport buffer_size = { socket; transport; buffer_size }

let handshake ({ socket; transport = (module T : Transport.Intf); _ } as t) =
  match T.handshake socket with Ok () -> Ok t | Error reason -> Error reason

let receive
    { socket; transport = (module T : Transport.Intf); buffer_size = len }
    ~timeout =
  T.receive ~timeout ~len socket

let send { socket; transport = (module T : Transport.Intf); _ } data =
  T.send data socket

let close { socket; transport = (module T : Transport.Intf); _ } =
  T.close socket
