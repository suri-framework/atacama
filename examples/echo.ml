[@@@warning "-8"]

open Riot

module Echo = struct
  open Atacama.Handler
  include Atacama.Handler.Default

  type state = int

  let handle_connection _socket state =
    Logger.info (fun f -> f "[%d] connection" state);
    Continue (state + 1)

  let handle_data data socket state =
    Logger.info (fun f -> f "[%d] echo: %S" state (Bigstringaf.to_string data));
    let (Ok _bytes) = Atacama.Socket.send socket data in
    Continue (state + 1)
end

let main () =
  Logger.set_log_level (Some Trace);
  let (Ok _) = Logger.start () in
  sleep 0.1;
  Logger.info (fun f -> f "starting atacama");
  let (Ok pid) = Atacama.start_link ~port:2112 (module Echo) 0 in
  wait_pids [ pid ];
  Logger.info (fun f -> f "closing down")

let () = Riot.run @@ main
