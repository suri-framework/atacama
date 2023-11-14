[@@@warning "-8"]

open Riot

module Echo = struct
  open Caravan.Handler
  include Caravan.Handler.Default

  type state = int

  let handle_connection _socket state =
    Logger.info (fun f -> f "[%d] connection" state);
    Continue (state + 1)

  let handle_data data socket state =
    Logger.info (fun f -> f "[%d] echo: %S" state (Bigstringaf.to_string data));
    let (Ok _bytes) = Caravan.Socket.send socket data in
    Continue (state + 1)
end

let main () =
  Riot.Net.Socket.Logger.set_log_level (Some Trace);
  Logger.set_log_level (Some Trace);
  let (Ok _) = Logger.start ~print_source:true () in
  sleep 0.1;
  Logger.info (fun f -> f "starting caravan");
  let (Ok pid) = Caravan.start_link ~port:2112 (module Echo) 0 in
  wait_pids [ pid ]

let () = Riot.run @@ main
