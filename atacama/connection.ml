open Riot

open Logger.Make (struct
  let namespace = [ "atacama"; "connection" ]
end)

let ( let* ) = Result.bind

type t =
  | Conn : {
      protocol : string option;
      writer : 'dst IO.Writer.t;
      reader : 'src IO.Reader.t;
      buffer : IO.Bytes.t;
      socket : Net.Socket.stream_socket;
      peer : Net.Addr.stream_addr;
    }
      -> t

let make ?(protocol = None) ~reader ~writer ~buffer_size:_ ~socket ~peer () =
  let buffer = IO.Bytes.empty in
  Conn { buffer; reader; writer; protocol; socket; peer }

let negotiated_protocol (Conn t) = t.protocol

let rec receive ?limit ?read_size (Conn { buffer; _ } as conn) =
  match (limit, read_size) with
  | None, None ->
      trace (fun f ->
          f "receive without limit or read_size (will use max buffer size= %d)"
            (IO.Bytes.length buffer));
      do_read conn
  | Some limit, None ->
      trace (fun f -> f "receive with limit of %d" limit);
      do_read ~buf:(IO.Bytes.with_capacity limit) conn
  | _, Some read_size ->
      let max_limit = IO.Bytes.length buffer in
      let limit = Option.value ~default:max_limit limit in
      let limit = Int.min limit max_limit in
      trace (fun f ->
          f "receive with read_size of %d (using limit=%d)" read_size limit);
      let read_buf = IO.Bytes.with_capacity read_size in
      do_read_until ~max_bytes:limit ~read_buf conn

and do_read_until ~max_bytes ~read_buf ?(data = IO.Bytes.of_string "") conn =
  trace (fun f -> f "read until limit=%d" max_bytes);
  let* chunk = do_read ~buf:read_buf conn in
  trace (fun f -> f "read chunk len=%d" (IO.Bytes.length chunk));
  let data = Bytes.cat data chunk in
  trace (fun f -> f "currently read=%d" (IO.Bytes.length data));
  if IO.Bytes.length data >= max_bytes then
    Ok (IO.Bytes.sub data ~pos:0 ~len:max_bytes)
  else do_read_until ~max_bytes ~read_buf ~data conn

and do_read ?buf (Conn { reader; buffer; _ }) =
  let buf = Option.value ~default:buffer buf in
  match IO.read ~buf reader with
  | Ok len -> Ok (IO.Bytes.sub buf ~pos:0 ~len)
  | Error err -> Error err

let peer (Conn { peer; _ }) = peer
let send (Conn { writer; _ }) buf = IO.write_all writer ~buf
let close (Conn { socket; _ }) = Net.Socket.close socket

let send_file (Conn { socket; _ }) ?off ~len file =
  File.send ?off ~len file socket
