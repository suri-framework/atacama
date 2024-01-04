[@@@warning "-8"]

open Riot

module Logger = Logger.Make (struct
  let namespace = [ "atacama"; "acceptor_pool" ]
end)

type ('ctx, 'err) state = {
  buffer_size : int;
  socket : Net.Socket.listen_socket;
  transport : Transport.t;
  initial_ctx : 'ctx;
  handler : (module Handler.Intf with type state = 'ctx and type error = 'err);
}

let rec accept_loop state =
  match Net.Socket.accept state.socket with
  | Ok (conn, client_addr) -> handle_conn state conn client_addr
  | Error err ->
      Logger.error (fun f ->
          f "Error accepting connection: %a" Net.Socket.pp_err err)

and handle_conn state conn client_addr =
  Logger.trace (fun f -> f "Accepted connection: %a" Net.Addr.pp client_addr);
  Telemetry_.accepted_connection client_addr;
  let (Ok _pid) =
    Connector.start_link ~transport:state.transport ~conn
      ~buffer_size:state.buffer_size ~handler:state.handler
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
  Supervisor.child_spec ~start_link state

module Sup = struct
  type ('ctx, 'err) state = {
    acceptor_count : int;
    buffer_size : int;
    handler_module :
      (module Handler.Intf with type state = 'ctx and type error = 'err);
    initial_ctx : 'ctx;
    port : int;
    transport : Transport.t;
  }

  let start_link
      {
        acceptor_count;
        buffer_size;
        handler_module;
        initial_ctx;
        port;
        transport;
      } =
    let opts =
      Net.Socket.
        {
          addr = Net.Addr.loopback;
          reuse_addr = true;
          reuse_port = false;
          backlog = 100;
        }
    in
    let (Ok socket) = Net.Socket.listen ~opts ~port () in
    Logger.debug (fun f -> f "Listening on 0.0.0.0:%d" port);
    Telemetry_.listening socket;
    let child_specs =
      List.init acceptor_count (fun _ ->
          child_spec ~socket ~buffer_size transport handler_module initial_ctx)
    in
    Supervisor.start_link ~child_specs ()

  let child_spec ~port ~acceptor_count ~transport ~handler_module ~buffer_size
      initial_ctx =
    let state =
      {
        acceptor_count;
        buffer_size;
        handler_module;
        initial_ctx;
        port;
        transport;
      }
    in
    Supervisor.child_spec ~start_link state
end
