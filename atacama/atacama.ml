module Telemetry = Telemetry_
module Connection = Connection
module Handler = Handler
module Transport = Transport
open Riot

let start_link ~port ?(acceptor_count = 100) ?(buffer_size = 1_024 * 50)
    ?(transport = Transport.tcp ()) handler_module initial_ctx =
  let child_specs =
    [
      Acceptor_pool.Sup.child_spec ~port ~acceptor_count ~transport ~buffer_size
        ~handler_module initial_ctx;
    ]
  in
  Supervisor.start_link ~restart_limit:10 ~child_specs ()
