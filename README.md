# Atacama

Atacama is a modern, pure OCaml socket pool for [Riot][riot] inspired by
[Thousand Island][thousand_island]. It aims to be easy to understand and reason
about, while also being at least as stable and performant as the alternatives.

[riot]: https://github.com/leostera/riot
[thousand_island]: https://github.com/mtrudel/thousand_island

## Getting Started

```
opam install atacama
```

## Usage

To start a Atacama server, you just specify a port to bind to, and a module
that will handle the connections.

``` ocaml
let (Ok pid) = Atacama.start_link ~port:2112 (module Echo) initial_state in
```

In this case, our `Echo` handler looks like this:

```ocaml
module Echo = struct
  open Atacama.Handler
  include Atacama.Handler.Default

  type state = int

  let handle_data data socket state =
    Logger.info (fun f -> f "[%d] echo: %s" state (Bigstringaf.to_string data));
    let (Ok _bytes) = Atacama.Socket.send socket data in
    Continue (state+1)
end
```

Custom lifecycle functions can be specified, but sensible defaults are
available in the `Atacama.Handler.Default` module that you can include to get
started quickly.

### Custom Transports

When starting a Atacama server, we can also specify a transport module.

```ocaml
let (Ok pid) = Atacama.start_link
    ~port:2112
    ~transport_module:(module Custom_transport)
    (module Echo) in
```

A transport is a module that implements `Atacama.Transport.Intf`, which defines
how to listen, connect, and accept sockets, how to handshake new connections, and how
to send and receive data.

Clear Tcp sockets are provided and used by default when starting a Atacama server.
