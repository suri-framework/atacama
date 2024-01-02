open Riot

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

let receive ?limit (Conn { reader; buffer = buf; _ }) =
  let buf =
    match limit with None -> buf | Some n -> IO.Buffer.with_capacity n
  in
  match IO.Reader.read ~buf reader with
  | Ok len -> Ok (IO.Buffer.sub buf ~off:0 ~len)
  | Error err -> Error err

let send (Conn { writer; _ }) data = IO.write_all writer ~data
let close (Conn { socket; _ }) = Net.Socket.close socket

let send_file (Conn { socket; _ }) ?off ~len file =
  File.send ?off ~len file socket
