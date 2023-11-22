[@@@warning "-8"]

open Riot

module Echo = struct
  module Server = struct
    open Atacama.Handler
    include Atacama.Handler.Default

    type state = int

    let handle_connection _socket state =
      Logger.info (fun f -> f "[%d] new connection" state);
      Continue (state + 1)

    let handle_data data socket state =
      Logger.info (fun f ->
          f "[%d] echo: %S" state (Bigstringaf.to_string data));
      let (Ok _bytes) = Atacama.Socket.send socket data in
      Continue (state + 1)
  end

  let start () = Atacama.start_link ~port:2112 (module Server) 0
  let name = "echo_server"
end

let () = Riot.start ~apps:[ (module Logger); (module Echo) ] ()
