open Riot

open Logger.Make (struct
  let namespace = [ "atacama"; "connector" ]
end)

type ('s, 'e) conn_fn =
  Connection.t ->
  (module Handler.Intf with type state = 's and type error = 'e) ->
  's ->
  unit

type ('state, 'err) state = {
  accepted_at : Ptime.t;
  transport : Transport.t;
  conn : Net.Socket.stream_socket;
  buffer_size : int;
  handler :
    (module Handler.Intf with type error = 'err and type state = 'state);
  peer : Net.Addr.stream_addr;
  ctx : 'state;
}

let rec loop : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  trace (fun f -> f "receiving process message...");
  match receive ~after:500L () with
  | exception Receive_timeout ->
      trace (fun f -> f "message timeout, trying receive...");
      try_receive conn handler ctx
  | msg -> (
      match Handler.handle_message handler msg conn ctx with
      | Continue ctx -> loop conn handler ctx
      | _ -> error (fun f -> f "unexpected value"))

and try_receive : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  trace (fun f -> f "Receiving...: %a" Pid.pp (self ()));
  match Connection.receive ~timeout:2_000L conn with
  | exception Syscall_timeout -> loop conn handler ctx
  | Ok zero when Bytestring.is_empty zero ->
      Handler.handle_close handler conn ctx
  | Ok data -> handle_data data conn handler ctx
  | Error (`Timeout | `Process_down) ->
      error (fun f -> f "Error receiving data: timeout")
  | Error ((`Closed | `Unix_error _ | _) as err) ->
      error (fun f -> f "Error receiving data: %a" IO.pp_err err)

and handle_data : type s e. Bytestring.t -> (s, e) conn_fn =
 fun data conn handler ctx ->
  trace (fun f -> f "Received data: %d octets" (Bytestring.length data));
  match Handler.handle_data handler data conn ctx with
  | Continue ctx -> loop conn handler ctx
  | Close ctx ->
      trace (fun f -> f "closing the conn");
      Handler.handle_close handler conn ctx
  | Switch (H { handler; state }) -> handle_connection conn handler state
  | Error (_state, err) ->
      error (fun f -> f "connection error: %a" (Handler.pp_err handler) err)
  | _ -> error (fun f -> f "unexpected value")

and handle_connection : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  match Handler.handle_connection handler conn ctx with
  | Continue ctx -> loop conn handler ctx
  | Switch (H { handler; state }) -> handle_connection conn handler state
  | _ -> ()

let init
    { accepted_at; transport; conn = socket; peer; buffer_size; handler; ctx } =
  let[@warning "-8"] (Ok conn) =
    Transport.handshake transport ~accepted_at ~socket ~peer ~buffer_size
  in
  trace (fun f -> f "Initialized conn: %a" Net.Socket.pp socket);
  Fun.protect
    ~finally:(fun () -> Connection.close conn)
    (fun () -> handle_connection conn handler ctx)

let start_link state =
  let pid = spawn_link (fun () -> init state) in
  Ok pid

let child_spec ~accepted_at ~transport ~conn ~buffer_size ~handler ~peer ~ctx ()
    =
  let state =
    { accepted_at; transport; conn; buffer_size; handler; peer; ctx }
  in
  Supervisor.child_spec start_link state
