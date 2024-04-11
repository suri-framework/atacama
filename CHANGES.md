# 0.0.5

* Bring up to latest Riot version – thanks @metame! :clap:

* Introduce `handle_message` callback to allow connector processes to receive
  out-of-band messages from other Riot processes

* Introduce configurable transports with their own configruation 

* Introduce configurable connection limits and a dynamic connection pool

* Introduce SSL Transport

* Introduce Connection Peer data including the address and port

* Expose new connection measurements such as time the connection was accepted
  (`accepted_at`) and time at which the connection was established (`connected_at`)

* Move to bytestrings and iovecs

* Default to not reusing ports

# 0.0.4

* Introduce Handler Switching – this lets a handler, at any point during the
  lifecycle, switch to a new handler and reinitizialize the connection.

  This is particularly useful for protocol upgrades such as going from HTTP/1.1
  to HTTP/2 or WebSockets.

* Introduce protocol negotiation to support SSL socket pools in Riot 0.0.8

* Expose a direct `Connection.receive` and allow reading an exact number of
  bytes from a connection (useful for sniffing)

* Introduce and update benchmarks in Go, Elixir, Erlang, Eio, and Rust

* Refactor Transport/Socket interfaces to reuse buffers

* Add `echo_test` to verify integrity of data

* Add working TCP echo server example

* Upgrade to Riot 0.0.7

# 0.0.3

* Move example to use Riot Applications
* Started reference projects for benchmarking
* Log socket accept/receive errors
* Always attempt to close a socket

# 0.0.2

* Update to work with Riot 0.0.3

# 0.0.1

First release includes:

* A pluggable architecture, where both Transports and Handlers can be
  configured in an Atacama supervision tree at startup time.

  This makes it easy to swap in the protocol used, which by default will be
  clear TCP sockets.

* Easy-to-define handlers using module includes, so defining a new handler is
  as little as ~5 lines of OCaml.

* A supervision tree for handling connections in an acceptor pool

* Custom state per connection pool

* An echo server example

* Some telemetry events

* Namespaced internal logging
