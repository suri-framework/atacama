open Riot

module Logger = Logger.Make (struct
  let namespace = [ "atacama"; "connection" ]
end)

let ( let* ) = Result.bind

type t =
  | Conn : {
      protocol : string option;
      writer : 'dst IO.Writer.t;
      reader : 'src IO.Reader.t;
      buffer : IO.Buffer.t;
      socket : Net.Socket.stream_socket;
    }
      -> t

let make ?(protocol = None) ~reader ~writer ~buffer_size ~socket () =
  let buffer = IO.Buffer.with_capacity buffer_size in
  Conn { buffer; reader; writer; protocol; socket }

let negotiated_protocol (Conn t) = t.protocol

let rec receive ?limit ?read_size (Conn { buffer; _ } as conn) =
  match (limit, read_size) with
  | None, None ->
      Logger.trace (fun f ->
          f "receive without limit or read_size (will use max buffer size= %d)"
            (IO.Buffer.length buffer));
      do_read conn
  | Some limit, None ->
      Logger.trace (fun f -> f "receive with limit of %d" limit);
      do_read ~buf:(IO.Buffer.with_capacity limit) conn
  | _, Some read_size ->
      let max_limit = IO.Buffer.length buffer in
      let limit = Option.value ~default:max_limit limit in
      let limit = Int.min limit max_limit in
      Logger.trace (fun f ->
          f "receive with read_size of %d (using limit=%d)" read_size limit);
      let read_buf = IO.Buffer.with_capacity read_size in
      do_read_until ~max_bytes:limit ~read_buf conn

and do_read_until ~max_bytes ~read_buf ?(data = IO.Buffer.empty) conn =
  Logger.trace (fun f -> f "read until limit=%d" max_bytes);
  let* chunk = do_read ~buf:read_buf conn in
  Logger.trace (fun f -> f "read chunk len=%d" (IO.Buffer.length chunk));
  let data = IO.Buffer.concat data chunk in
  Logger.trace (fun f -> f "currently read=%d" (IO.Buffer.length data));
  if IO.Buffer.length data >= max_bytes then
    Ok (IO.Buffer.sub data ~len:max_bytes)
  else do_read_until ~max_bytes ~read_buf ~data conn

and do_read ?buf (Conn { reader; buffer; _ }) =
  let buf = Option.value ~default:buffer buf in
  match IO.Reader.read ~buf reader with
  | Ok len -> Ok (IO.Buffer.sub buf ~off:0 ~len)
  | Error err -> Error err

let send (Conn { writer; _ }) data = IO.write_all writer ~data
let close (Conn { socket; _ }) = Net.Socket.close socket

let send_file (Conn { socket; _ }) ?off ~len file =
  File.send ?off ~len file socket
