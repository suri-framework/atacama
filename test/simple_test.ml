[@@@warning "-8"]

open Riot

module Echo : Caravan.Handler.Intf = struct
  open Caravan.Handler
  include Caravan.Handler.Default

  let handle_data data socket state =
    let (Ok _bytes) = Caravan.Socket.send socket data in
    Continue state
end

let main () =
  Riot.Socket.Logger.set_log_level (Some Trace);
  Logger.set_log_level (Some Trace);
  let (Ok _) = Logger.start () in
  sleep 0.1;
  Logger.info (fun f -> f "starting caravan");
  let (Ok pid) = Caravan.start_link ~port:2112 (module Echo) in
  wait_pids [ pid ]

let () = Riot.run @@ main
