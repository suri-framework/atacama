open Riot

let rec loop conn handler ctx =
  match Connection.receive conn with
  | Ok data -> handle_data conn handler ctx data
  | Error `Eof -> Logger.error (fun f -> f "Error receiving data: end of file")
  | Error ((`Closed | `Unix_error _) as err) ->
      Logger.error (fun f -> f "Error receiving data: %a" Net.Socket.pp_err err)

and handle_data conn handler ctx data =
  Logger.debug (fun f -> f "Received data: %S" (IO.Buffer.to_string data));
  match Handler.handle_data handler data conn ctx with
  | Continue ctx -> loop conn handler ctx
  | Close ctx ->
      Logger.debug (fun f -> f "closing the conn");
      Handler.handle_close handler conn ctx
  | _ -> Logger.debug (fun f -> f "unexpected value")

let init (module Transport : Transport.Intf) socket buffer_size handler ctx =
  let[@warning "-8"] (Ok conn) = Transport.handshake ~socket ~buffer_size in
  Logger.debug (fun f -> f "Initialized conn: %a" Net.Socket.pp socket);
  match Handler.handle_connection handler conn ctx with
  | Continue ctx -> loop conn handler ctx
  | _ -> ()

let start_link ~transport ~conn ~buffer_size ~handler ~ctx () =
  let pid =
    spawn_link (fun () -> init transport conn buffer_size handler ctx)
  in
  Ok pid
