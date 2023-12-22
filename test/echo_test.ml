open Riot

type Message.t += Received of string

module Echo_server = struct
  open Atacama.Handler
  include Atacama.Handler.Default

  type state = int

  let handle_data data socket state =
    match Atacama.Socket.send socket data with
    | Ok _bytes -> Continue (state + 1)
    | Error _ -> Close state
end

let client port main =
  let addr = Net.Addr.(tcp loopback port) in
  let conn = Net.Socket.connect addr |> Result.get_ok in
  Logger.debug (fun f -> f "Connected to server on %d" port);
  let data = "hello world" in
  let data = Bigstringaf.of_string data ~off:0 ~len:(String.length data) in
  let rec send_loop n =
    sleep 0.001;
    if n = 0 then Logger.error (fun f -> f "client retried too many times")
    else
      match Net.Socket.send ~data conn with
      | Ok bytes -> Logger.debug (fun f -> f "Client sent %d bytes" bytes)
      | Error `Closed -> Logger.debug (fun f -> f "connection closed")
      | Error (`Unix_error (ENOTCONN | EPIPE)) -> send_loop n
      | Error (`Unix_error unix_err) ->
          Logger.error (fun f ->
              f "client unix error %s" (Unix.error_message unix_err));
          send_loop (n - 1)
  in
  send_loop 10_000;

  let buf = Bigstringaf.create 128 in
  let recv_loop () =
    match Net.Socket.receive ~buf conn with
    | Ok bytes ->
        Logger.debug (fun f -> f "Client received %d bytes" bytes);
        bytes
    | Error (`Closed | `Timeout) ->
        Logger.debug (fun f -> f "Server closed the connection");
        0
    | Error (`Unix_error unix_err) ->
        Logger.error (fun f ->
            f "client unix error %s" (Unix.error_message unix_err));
        0
  in
  let len = recv_loop () in

  if len = 0 then send main (Received "empty paylaod")
  else send main (Received (Bigstringaf.substring buf ~off:0 ~len))

let () =
  Riot.run @@ fun () ->
  let _ = Logger.start () |> Result.get_ok in
  Logger.set_log_level (Some Info);
  let port = 2112 in
  let main = self () in
  let _server = Atacama.start_link ~port (module Echo_server) 0 in
  let _client = spawn (fun () -> client port main) in
  match receive () with
  | Received "hello world" ->
      Logger.info (fun f -> f "net_test: OK");
      sleep 0.001;
      shutdown ()
  | Received other ->
      Logger.error (fun f -> f "net_test: bad payload: %S" other);
      sleep 0.001;
      Stdlib.exit 1
  | _ ->
      Logger.error (fun f -> f "net_test: unexpected message");
      sleep 0.001;
      Stdlib.exit 1
