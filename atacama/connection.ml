open Riot

let rec loop : Socket.t -> 's Handler.t -> 's -> unit =
 fun socket handler ctx ->
  match Socket.receive socket ~timeout:Net.Socket.Infinity with
  | Ok data -> handle_data socket handler ctx data
  | Error err ->
      Logger.error (fun f -> f "Error receiving data: %a" Net.Socket.pp_err err)

and handle_data socket handler ctx data =
  Logger.debug (fun f -> f "Received data: %S" (Bigstringaf.to_string data));
  match Handler.handle_data handler data socket ctx with
  | Continue ctx -> loop socket handler ctx
  | Close ctx ->
      Logger.debug (fun f -> f "closing the socket: %a" Socket.pp socket);
      Handler.handle_close handler socket ctx
  | _ -> Logger.debug (fun f -> f "unexpected value: %a" Socket.pp socket)

let init : Socket.t -> 's Handler.t -> 's -> unit =
 fun socket handler ctx ->
  let[@warning "-8"] (Ok socket) = Socket.handshake socket in
  Logger.debug (fun f -> f "Initialized socket: %a" Socket.pp socket);
  match Handler.handle_connection handler socket ctx with
  | Continue ctx -> loop socket handler ctx
  | _ -> ()

let start_link socket handler ctx =
  let pid =
    spawn_link (fun () ->
        Fun.protect
          ~finally:(fun () -> Socket.close socket)
          (fun () -> init socket handler ctx))
  in
  Ok pid
