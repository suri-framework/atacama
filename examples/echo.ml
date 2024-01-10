[@@@warning "-8"]

open Riot

module Echo = struct
  module Server = struct
    open Atacama.Handler
    include Atacama.Handler.Default

    type state = int
    type error = [ `noop ]

    let pp_err fmt `noop = Format.fprintf fmt "Noop"

    let handle_data data socket state =
      Logger.info (fun f -> f "[%d] echo: %S" state (Bytestring.to_string data));
      match Atacama.Connection.send socket data with
      | Ok _bytes -> Continue (state + 1)
      | Error _ -> Close state
  end

  let start () =
    Logger.set_log_level (Some Debug);
    Atacama.start_link ~port:2112 (module Server) 0
end

let () = Riot.start ~apps:[ (module Logger); (module Echo) ] ()
