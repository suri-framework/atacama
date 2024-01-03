open Riot

type ('s, 'e) conn_fn =
  Connection.t ->
  (module Handler.Intf with type state = 's and type error = 'e) ->
  's ->
  unit

let rec loop : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  match Connection.receive conn with
  | Ok data -> handle_data data conn handler ctx
  | Error (`Timeout | `Process_down) ->
      Logger.error (fun f -> f "Error receiving data: timeout")
  | Error ((`Closed | `Unix_error _) as err) ->
      Logger.error (fun f -> f "Error receiving data: %a" Net.Socket.pp_err err)

and handle_data : type s e. IO.Buffer.t -> (s, e) conn_fn =
 fun data conn handler ctx ->
  Logger.trace (fun f -> f "Received data: %S" (IO.Buffer.to_string data));
  match Handler.handle_data handler data conn ctx with
  | Continue ctx -> loop conn handler ctx
  | Close ctx ->
      Logger.trace (fun f -> f "closing the conn");
      Handler.handle_close handler conn ctx
  | Switch (H { handler; state }) -> handle_connection conn handler state
  | Error (_state, error) ->
      Logger.error (fun f ->
          f "connection error: %a" (Handler.pp_err handler) error)
  | _ -> Logger.error (fun f -> f "unexpected value")

and handle_connection : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  match Handler.handle_connection handler conn ctx with
  | Continue ctx -> loop conn handler ctx
  | Switch (H { handler; state }) -> handle_connection conn handler state
  | _ -> ()

let init transport socket buffer_size handler ctx =
  let[@warning "-8"] (Ok conn) =
    Transport.handshake transport ~socket ~buffer_size
  in
  Logger.trace (fun f -> f "Initialized conn: %a" Net.Socket.pp socket);
  Fun.protect
    ~finally:(fun () -> Connection.close conn)
    (fun () -> handle_connection conn handler ctx)

let start_link ~transport ~conn ~buffer_size ~handler ~ctx () =
  let pid =
    spawn_link (fun () -> init transport conn buffer_size handler ctx)
  in
  Ok pid
