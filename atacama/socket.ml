open Riot

type t = {
  socket : Net.Socket.stream_socket;
  transport : (module Transport.Intf);
  buffer : Bigstringaf.t;
}

let pp ppf t = Format.fprintf ppf "Socket<%d>" (Obj.magic t.socket)
let make socket transport buffer = { socket; transport; buffer }

let handshake ({ socket; transport = (module T : Transport.Intf); _ } as t) =
  match T.handshake socket with Ok () -> Ok t | Error reason -> Error reason

let receive { socket; transport = (module T : Transport.Intf); buffer = buf }
    ~timeout =
  match T.receive ~timeout ~buf socket with
  | Ok len -> Ok (Bigstringaf.sub buf ~off:0 ~len)
  | Error err -> Error err

let send { socket; transport = (module T : Transport.Intf); _ } data =
  T.send ~data socket

let close { socket; transport = (module T : Transport.Intf); _ } =
  T.close socket
