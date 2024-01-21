open Riot

let data = {%b| "HTTP/1.1 200 OK\r\nContent-Length: 12\r\n\r\nhello world!" |}

module Http = struct
  module Server = struct
    open Atacama.Handler
    include Atacama.Handler.Default

    type state = int
    type error = [ `noop ]

    let pp_err fmt `noop = Format.fprintf fmt "Noop"

    let handle_data _data socket state =
      match Atacama.Connection.send socket data with
      | Ok _bytes -> Continue (state + 1)
      | Error _ -> Close state
  end

  let start () =
    (* Runtime.set_log_level (Some Debug); *)
    (* Logger.set_log_level (Some Debug); *)
    (* Runtime.Stats.start ~every:2_000_000L (); *)
    Atacama.start_link ~buffer_size:(1024 * 50) ~port:2113 (module Server) 0
end

let () = Riot.start ~apps:[ (module Logger); (module Http) ] ()
