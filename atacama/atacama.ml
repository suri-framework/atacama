module Telemetry = Telemetry_
module Socket = Socket
module Handler = Handler
module Transport = Transport
open Riot

let start_link ~port ?(acceptor_count = 100) ?(buffer_size = 1_024 * 50)
    ?(transport_module = (module Transport.Tcp : Transport.Intf)) handler_module
    initial_ctx =
  let child_specs =
    [
      Acceptor_pool.Sup.child_spec ~port ~acceptor_count ~transport_module
        ~buffer_size ~handler_module initial_ctx;
    ]
  in
  Supervisor.start_link ~restart_limit:10 ~child_specs ()
