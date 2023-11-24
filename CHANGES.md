# Changes

## 0.0.3

* Move example to use Riot Applications
* Started reference projects for benchmarking
* Log socket accept/receive errors
* Always attempt to close a socket

## 0.0.2

* Update to work with Riot 0.0.3

## 0.0.1

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
