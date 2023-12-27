open Riot

let ( let* ) = Result.bind

type t =
  | Conn : {
      writer : 'socket IO.Writer.t;
      reader : 'socket IO.Reader.t;
      buffer : IO.Buffer.t;
    }
      -> t

let make ~reader ~writer ~buffer_size =
  let buffer = IO.Buffer.with_capacity buffer_size in
  Conn { buffer; reader; writer }

let receive (Conn { reader; buffer = buf; _ }) =
  match IO.Reader.read ~buf reader with
  | Ok len -> Ok (IO.Buffer.sub buf ~off:0 ~len)
  | Error err -> Error err

let send (Conn { writer; _ }) data = IO.write_all writer ~data
