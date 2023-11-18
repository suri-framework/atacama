open Riot

type Telemetry.event +=
  | Accepted_connection of { client_addr : Net.Addr.stream_addr }
  | Connection_started
  | Listening of { socket : Net.Socket.listen_socket }

let accepted_connection client_addr =
  Telemetry.emit (Accepted_connection { client_addr })

let connection_started () = Telemetry.emit Connection_started
let listening socket = Telemetry.emit (Listening { socket })
