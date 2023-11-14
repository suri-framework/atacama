[@@@warning "-8"]

open Riot

let rec loop : Socket.t -> 's Handler.t -> 's -> unit =
 fun socket handler ctx ->
  let (Ok data) = Socket.receive socket ~timeout:Net.Socket.Infinity in
  match Handler.handle_data handler data socket ctx with
  | Handler.Continue ctx -> loop socket handler ctx

let init : Socket.t -> 's Handler.t -> 's -> unit =
 fun socket handler ctx ->
  Logger.debug (fun f -> f "accepted connection");
  let (Ok socket) = Socket.handshake socket in
  match Handler.handle_connection handler socket ctx with
  | Handler.Continue ctx -> loop socket handler ctx
  | _ -> assert false

let start_link socket handler ctx =
  let pid = spawn_link (fun () -> init socket handler ctx) in
  Ok pid
