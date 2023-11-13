[@@@warning "-8"]

open Riot

type 's state = { ctx : 's; socket : Socket.t; handler : (module Handler.Intf) }

let rec loop state =
  let (Ok data) = Socket.receive state.socket ~timeout:Net.Socket.Infinity in
  let module H = (val state.handler : Handler.Intf) in
  match H.handle_data data state.socket state.ctx with
  | Handler.Continue ctx -> loop { state with ctx }

let init ({ socket; handler = (module H : Handler.Intf); ctx } as state) =
  Logger.debug (fun f -> f "accepted connection");
  let (Ok socket) = Socket.handshake socket in
  match H.handle_connection socket ctx with
  | Handler.Continue ctx -> loop { state with ctx }
  | _ -> assert false

let start_link socket handler ctx =
  let state = { socket; handler; ctx } in
  let pid = spawn_link (fun () -> init state) in
  Ok pid
