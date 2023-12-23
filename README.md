<div align="center">
  <img src="./doc/header.jpg" alt="">
  <h1>Atacama</h1>
  <p>A modern, pure OCaml socket pool for
    <a href="https://github.com/leostera/riot">Riot</a>
    inspired by
    <a href="https://github.com/mtrudel/thousand_island">Thousand Island</a>.
    It aims to be easy to understand and reason about, while also being at least
    as stable and performant as the alternatives.
  </p>
</div>

## Getting Started

```
opam install atacama
```

## Usage

To start a Atacama server, you just specify a port to bind to, and a module that
will handle the connections.

```ocaml
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

Custom lifecycle functions can be specified, but sensible defaults are available
in the `Atacama.Handler.Default` module that you can include to get started
quickly.

### Custom Transports

When starting an Atacama server, we can also specify a transport module.

Transport is a module that implements `Atacama.Transport.Intf`, which defines
how to listen, connect, and accept sockets, how to handshake new connections,
and how to send and receive data.

Clear TCP sockets are provided and used by default when starting an Atacama
server.
