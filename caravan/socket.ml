open Riot

type t = { socket : Net.stream_socket; transport : (module Transport.Intf) }

let make socket transport = { socket; transport }

let handshake ({ socket; transport = (module T : Transport.Intf) } as t) =
  match T.handshake socket with Ok () -> Ok t | Error reason -> Error reason

let send { socket; transport = (module T : Transport.Intf) } data =
  T.send data socket
