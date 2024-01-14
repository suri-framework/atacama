open Riot

module Logger = Logger.Make (struct
  let namespace = [ "atacama"; "acceptor_pool" ]
end)

type ('ctx, 'err) state = {
  acceptors : int;
  buffer_size : int;
  handler : (module Handler.Intf with type state = 'ctx and type error = 'err);
  initial_ctx : 'ctx;
  port : int;
  transport : Transport.t;
}

let start_link { acceptors; buffer_size; handler; initial_ctx; port; transport }
    =
  let opts =
    Net.Tcp_listener.
      {
        addr = Net.Addr.loopback;
        reuse_addr = true;
        reuse_port = false;
        backlog = 100;
      }
  in
  let[@warning "-8"] (Ok socket) = Net.Tcp_listener.bind ~opts ~port () in
  Logger.debug (fun f -> f "Listening on 0.0.0.0:%d" port);
  Telemetry_.listening socket;
  let child_specs =
    List.init acceptors (fun _ ->
        Acceptor.child_spec ~socket ~buffer_size transport handler initial_ctx)
  in
  Supervisor.start_link ~child_specs ()

let child_spec ~port ~acceptors ~transport ~handler ~buffer_size initial_ctx =
  let state =
    { acceptors; buffer_size; handler; initial_ctx; port; transport }
  in
  Supervisor.child_spec start_link state
