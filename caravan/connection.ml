open Riot

type state = {
  connection : Net.stream_socket;
  transport : (module Transport.Intf);
  handler : (module Handler.Intf);
}

let loop _state =
  Logger.debug (fun f -> f "accepted connection");
  ()

let start_link connection transport handler =
  let state = { connection; transport; handler } in
  let pid = spawn_link (fun () -> loop state) in
  Ok pid
