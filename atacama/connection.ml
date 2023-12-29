open Riot

let ( let* ) = Result.bind

type t =
  | Conn : {
      protocol : string option;
      writer : 'dst IO.Writer.t;
      reader : 'src IO.Reader.t;
      buffer : IO.Buffer.t;
    }
      -> t

let empty : t = 
  let buffer = IO.Buffer.with_capacity 0 in
  let reader = IO.Reader.of_buffer buffer in
  let file = File.open_write "/dev/null" in
  let writer = File.to_writer file in
  Conn { protocol = None; writer; reader; buffer }

let make ?(protocol = None) ~reader ~writer ~buffer_size () =
  let buffer = IO.Buffer.with_capacity buffer_size in
  Conn { buffer; reader; writer; protocol }

let negotiated_protocol (Conn t) = t.protocol

let receive ?limit (Conn { reader; buffer = buf; _ }) =
  let buf =
    match limit with None -> buf | Some n -> IO.Buffer.with_capacity n
  in
  match IO.Reader.read ~buf reader with
  | Ok len -> Ok (IO.Buffer.sub buf ~off:0 ~len)
  | Error err -> Error err

let send (Conn { writer; _ }) data = IO.write_all writer ~data
