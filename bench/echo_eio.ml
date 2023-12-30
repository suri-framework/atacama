open Eio.Std

let addr = `Tcp (Eio.Net.Ipaddr.V4.loopback, 2112)

module Server = struct
  module Read = Eio.Buf_read

  let handle_client flow _addr =
    let data = Read.of_flow flow ~max_size:(1024 * 50) in
    Eio.Flow.copy (Read.as_flow data) flow

  let run domain_mgr socket =
    let thread_count = Domain.recommended_domain_count () - 1 in
    Eio.Net.run_server ~additional_domains:(domain_mgr, thread_count) socket
      handle_client
      ~on_error:(traceln "Error handling connection: %a" Fmt.exn)
end

let main ~net ~domain_mgr =
  Switch.run @@ fun sw ->
  let listening_socket =
    Eio.Net.listen net ~sw ~reuse_port:true ~reuse_addr:true ~backlog:100 addr
  in
  Server.run domain_mgr listening_socket

let () =
  Eio_main.run @@ fun env ->
  main ~net:(Eio.Stdenv.net env) ~domain_mgr:(Eio.Stdenv.domain_mgr env)
