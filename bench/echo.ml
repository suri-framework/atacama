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
      match Atacama.Socket.send socket data with
      | Ok _bytes -> Continue (state + 1)
      | Error _ -> Close state
  end

  let start () =
    Atacama.start_link ~acceptor_count:100 ~port:2112 (module Server) 0

  let name = "echo_server"
end

let () = Riot.start ~apps:[ (module Logger); (module Echo) ] ()
