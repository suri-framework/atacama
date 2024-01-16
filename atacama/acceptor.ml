[@@@warning "-8"]

open Riot

module Logger = Logger.Make (struct
  let namespace = [ "atacama"; "acceptor" ]
end)

type ('ctx, 'err) state = {
  buffer_size : int;
  socket : Net.Socket.listen_socket;
  transport : Transport.t;
  initial_ctx : 'ctx;
  handler : (module Handler.Intf with type state = 'ctx and type error = 'err);
  max_connections : int;
  open_connections : int;
}

let rec accept_loop state =
  match Net.Tcp_listener.accept state.socket with
  | Ok (conn, peer) -> handle_conn state conn peer
  | Error err ->
      Logger.error (fun f -> f "Error accepting connection: %a" IO.pp_err err)

and handle_conn state conn peer =
  wait_for_open_slot state @@ fun () ->
  let accepted_at = Ptime_clock.now () in
  Logger.trace (fun f -> f "Accepted connection: %a" Net.Addr.pp peer);
  Telemetry_.accepted_connection peer;
  let (Ok _pid) =
    Connector.start_link ~accepted_at ~transport:state.transport ~conn
      ~buffer_size:state.buffer_size ~handler:state.handler ~peer
      ~ctx:state.initial_ctx ()
  in
  accept_loop { state with open_connections = state.open_connections + 1 }

and wait_for_open_slot state fn =
  let open_connections = state.open_connections + 1 in
  if open_connections < state.max_connections then fn ()
  else (
    sleep 0.100;
    wait_for_open_slot state fn)

let start_link state =
  let pid =
    spawn_link (fun () ->
        process_flag (Trap_exit true);
        accept_loop state)
  in
  Ok pid

let child_spec ~socket ?(max_connections = 1024) ?(buffer_size = 1_024 * 50)
    transport handler initial_ctx =
  let state =
    {
      socket;
      buffer_size;
      transport;
      handler;
      initial_ctx;
      max_connections;
      open_connections = 0;
    }
  in
  Supervisor.child_spec start_link state
