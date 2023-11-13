[@@@warning "-8"]

open Riot

type state = {
  buffer_size : int;
  socket : Net.listen_socket;
  transport : (module Transport.Intf);
  handler : (module Handler.Intf);
}

let rec accept_loop state =
  let (Ok (conn, client_addr)) = Riot.Net.Socket.accept state.socket in
  Telemetry_.accepted_connection client_addr;
  let conn = Socket.make conn state.transport state.buffer_size in
  let (Ok _pid) = Connection.start_link conn state.handler () in
  accept_loop state

let start_link state =
  let pid =
    spawn_link (fun () ->
        process_flag (Trap_exit true);
        accept_loop state)
  in
  Ok pid

let child_spec ~socket ?(buffer_size = 128) (module T : Transport.Intf)
    (module H : Handler.Intf) =
  let state =
    { socket; buffer_size; transport = (module T); handler = (module H) }
  in
  Supervisor.child_spec ~start_link state

module Sup = struct
  type state = {
    port : int;
    acceptor_count : int;
    transport_module : (module Transport.Intf);
    handler_module : (module Handler.Intf);
  }

  let start_link { port; acceptor_count; transport_module; handler_module } =
    let (Ok socket) = Riot.Net.Socket.listen ~port () in
    Telemetry_.listening socket;
    let child_specs =
      List.init acceptor_count (fun _ ->
          child_spec ~socket transport_module handler_module)
    in
    Supervisor.start_link ~child_specs ()

  let child_spec ~port ~acceptor_count ~transport_module ~handler_module =
    let state = { acceptor_count; port; transport_module; handler_module } in
    Supervisor.child_spec ~start_link state
end
