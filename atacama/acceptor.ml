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
}

let rec accept_loop state =
  match Net.Tcp_listener.accept state.socket with
  | Ok (conn, peer) -> handle_conn state conn peer
  | Error err ->
      Logger.error (fun f -> f "Error accepting connection: %a" IO.pp_err err)

and handle_conn state conn peer =
  let accepted_at = Ptime_clock.now () in
  Logger.trace (fun f -> f "Accepted connection: %a" Net.Addr.pp peer);
  Telemetry_.accepted_connection peer;
  let (Ok _pid) =
    Connector.start_link ~accepted_at ~transport:state.transport ~conn
      ~buffer_size:state.buffer_size ~handler:state.handler ~peer
      ~ctx:state.initial_ctx ()
  in
  accept_loop state

let start_link state =
  let pid =
    spawn_link (fun () ->
        process_flag (Trap_exit true);
        accept_loop state)
  in
  Ok pid

let child_spec ~socket ?(buffer_size = 1_024 * 50) transport handler initial_ctx
    =
  let state = { socket; buffer_size; transport; handler; initial_ctx } in
  Supervisor.child_spec start_link state
