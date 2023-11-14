module Logger = Logger
module Telemetry = Telemetry
module Socket = Socket
module Handler = Handler
module Transport = Transport
open Riot

let start_link ~port ?(acceptor_count = 100)
    ?(transport_module = (module Transport.Tcp : Transport.Intf)) handler_module
    initial_ctx =
  let child_specs =
    [
      Acceptor_pool.Sup.child_spec ~port ~acceptor_count ~transport_module
        ~handler_module initial_ctx;
    ]
  in
  Supervisor.start_link ~child_specs ()
