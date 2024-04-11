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
      socket : Net.Socket.stream_socket;
      peer : Net.Addr.stream_addr;
      default_read_size : int;
      accepted_at : Ptime.t;
      connected_at : Ptime.t;
    }
      -> t

let make ?(protocol = None) ~accepted_at ~reader ~writer ~buffer_size ~socket
    ~peer () =
  Conn
    {
      reader;
      writer;
      protocol;
      socket;
      peer;
      default_read_size = buffer_size;
      accepted_at;
      connected_at = Ptime_clock.now ();
    }

let negotiated_protocol (Conn t) = t.protocol

let receive ?timeout ?(limit = 1024) ?read_size
    (Conn { default_read_size; reader; _ }) =
  let read_size = Option.value read_size ~default:default_read_size in
  trace (fun f ->
      f "receive with read_size of %d (using limit=%d)" read_size limit);
  let capacity = Int.min limit read_size in
  Bytestring.with_bytes ~capacity @@ fun buf -> IO.read ?timeout reader buf

let rec send conn buf =
  let bufs = Bytestring.to_iovec buf in
  let len = IO.Iovec.length bufs in
  trace (fun f -> f "will send %d bytes" len);
  let* () = do_send conn bufs len in
  trace (fun f -> f "sent %d bytes" len);
  Ok ()

and do_send (Conn { writer; _ } as conn) bufs len =
  let* written = IO.write_owned_vectored writer ~bufs in
  trace (fun f -> f "sent %d bytes" written);
  let len = len - written in
  trace (fun f -> f "left to send %d bytes" len);
  if len = 0 then Ok ()
  else
    let bufs = IO.Iovec.sub ~pos:written ~len bufs in
    do_send conn bufs len

let peer (Conn { peer; _ }) = peer
let connected_at (Conn { connected_at; _ }) = connected_at
let accepted_at (Conn { accepted_at; _ }) = accepted_at

let close (Conn { socket; accepted_at; _ }) =
  Net.Tcp_stream.close socket;
  debug (fun f ->
      let end_time = Ptime_clock.now () in
      let diff = Ptime.diff end_time accepted_at in
      f "Connection handled in %a" Ptime.Span.pp diff)

let send_file (Conn _) ?off:_ ~len:_ _file =
  (* File.send ?off ~len file socket *)
  Ok ()
