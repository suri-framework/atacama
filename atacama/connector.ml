open Riot

open Logger.Make (struct
  let namespace = [ "atacama"; "connector" ]
end)

type ('s, 'e) conn_fn =
  Connection.t ->
  (module Handler.Intf with type state = 's and type error = 'e) ->
  's ->
  unit

let rec loop : type s e. (s, e) conn_fn =
 fun conn handler ctx ->
  trace (fun f -> f "Receiving...: %a" Pid.pp (self ()));
  match Connection.receive conn with
  | Ok data -> handle_data data conn handler ctx
  | Error (`Timeout | `Process_down) ->
      error (fun f -> f "Error receiving data: timeout")
  | Error ((`Closed | `Unix_error _) as err) ->
      error (fun f -> f "Error receiving data: %a" Net.Socket.pp_err err)

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

let init accepted_at transport socket peer buffer_size handler ctx =
  let[@warning "-8"] (Ok conn) =
    Transport.handshake transport ~accepted_at ~socket ~peer ~buffer_size
  in
  trace (fun f -> f "Initialized conn: %a" Net.Socket.pp socket);
  Fun.protect
    ~finally:(fun () -> Connection.close conn)
    (fun () -> handle_connection conn handler ctx)

let start_link ~accepted_at ~transport ~conn ~peer ~buffer_size ~handler ~ctx ()
    =
  let pid =
    spawn_link (fun () ->
        init accepted_at transport conn peer buffer_size handler ctx)
  in
  Ok pid
