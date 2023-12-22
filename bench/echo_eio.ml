open Eio.Std

let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, 2112)

module Server = struct
  module Read = Eio.Buf_read

  let handle_client flow _addr =
    let data = Read.of_flow flow ~max_size:128 in
    Eio.Flow.copy (Read.as_flow data) flow

  let run socket =
    Eio.Net.run_server socket handle_client
      ~on_error:(traceln "Error handling connection: %a" Fmt.exn)
      ~max_connections:100
end

let main ~net ~domain_mgr =
  Switch.run @@ fun sw ->
  let thread_count = Domain.recommended_domain_count () - 1 in
  List.init thread_count (fun tid ->
      Fiber.fork ~sw @@ fun () ->
      Eio.Domain_manager.run domain_mgr @@ fun () ->
      Switch.run @@ fun sw ->
      Printf.printf "Listening :2112 from thread %d\n%!" tid;
      let listening_socket =
        Eio.Net.listen net ~sw ~reuse_port:true ~reuse_addr:true ~backlog:100 addr
      in
      Server.run listening_socket)
  |> ignore

let () =
  Eio_main.run @@ fun env ->
  main ~net:(Eio.Stdenv.net env) ~domain_mgr:(Eio.Stdenv.domain_mgr env)
