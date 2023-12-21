[@@@warning "-8"]

open Riot

type 'ctx state = {
  buffer_size : int;
  socket : Net.Socket.listen_socket;
  transport : (module Transport.Intf);
  initial_ctx : 'ctx;
  handler : 'ctx Handler.t;
}

let rec accept_loop state =
  match Net.Socket.accept state.socket with
  | Ok (conn, client_addr) -> handle_conn state conn client_addr
  | Error err ->
      Logger.error (fun f ->
          f "Error accepting connection: %a" Net.Socket.pp_err err)

and handle_conn state conn client_addr =
  Logger.debug (fun f -> f "Accepted connection: %a" Net.Addr.pp client_addr);
  Telemetry_.accepted_connection client_addr;
  let buffer = Bigstringaf.create state.buffer_size in
  let conn = Socket.make conn state.transport buffer in
  let (Ok _pid) = Connection.start_link conn state.handler state.initial_ctx in
  accept_loop state

let start_link state =
  let pid =
    spawn_link (fun () ->
        process_flag (Trap_exit true);
        accept_loop state)
  in
  Ok pid

let child_spec ~socket ?(buffer_size = 1024) transport handler initial_ctx =
  let state = { socket; buffer_size; transport; handler; initial_ctx } in
  Supervisor.child_spec ~start_link state

module Sup = struct
  type 'ctx state = {
    port : int;
    acceptor_count : int;
    transport_module : (module Transport.Intf);
    handler_module : 'ctx Handler.t;
    initial_ctx : 'ctx;
  }

  let start_link
      { port; acceptor_count; transport_module; handler_module; initial_ctx } =
    let (Ok socket) = Net.Socket.listen ~port () in
    Logger.debug (fun f -> f "Listening on 0.0.0.0:%d" port);
    Telemetry_.listening socket;
    let child_specs =
      List.init acceptor_count (fun _ ->
          child_spec ~socket transport_module handler_module initial_ctx)
    in
    Supervisor.start_link ~child_specs ()

  let child_spec ~port ~acceptor_count ~transport_module ~handler_module
      initial_ctx =
    let state =
      { acceptor_count; port; transport_module; handler_module; initial_ctx }
    in
    Supervisor.child_spec ~start_link state
end
