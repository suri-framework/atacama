# Caravan

Caravan is a modern, pure OCaml socket pool for [Riot][riot] inspired by
[Thousand Island][thousand_island]. It aims to be easy to understand and reason
about, while also being at least as stable and performant as the alternatives.

[riot]: https://github.com/leostera/riot
[thousand_island]: https://github.com/mtrudel/thousand_island

## Getting Started

```
opam install caravan
```

## Usage

To start a Caravan server, you just specify a port to bind to, and a module
that will handle the connections.

``` ocaml
let (Ok pid) = Caravan.start_link ~port:2112 (module Echo) in
```

In this case, our `Echo` handler looks like this:

```ocaml
module Echo = struct
  open Caravan.Handler
  include Caravan.Handler.Default

  let handle_data data socket state =
    Logger.info (fun f -> f "echo: %s" (Bigstringaf.to_string data));
    let (Ok _bytes) = Caravan.Socket.send socket data in
    Continue state
end
```

### Custom Transports

When starting a Caravan server, we can also specify a transport module.

```ocaml
let (Ok pid) = Caravan.start_link
    ~port:2112
    ~transport_module:(module Custom_transport)
    (module Echo) in
```

A transport is a module that implements `Caravan.Transport.Intf`, which defines
how to listen, connect, and accept sockets, how to handshake new connections, and how
to send and receive data.

Clear Tcp sockets are provided and used by default when starting a Caravan server.
