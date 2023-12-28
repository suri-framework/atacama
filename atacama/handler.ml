open Riot

type ('state, 'error) handler_result =
  | Ok
  | Continue of 'state
  | Continue_with_timeout of 'state * Timeout.t
  | Close of 'state
  | Error of 'state * 'error

module type Intf = sig
  type state

  val handle_close : Connection.t -> state -> unit

  val handle_connection :
    Connection.t -> state -> (state, 'error) handler_result

  val handle_data :
    IO.Buffer.t -> Connection.t -> state -> (state, 'error) handler_result

  val handle_error :
    'error -> Connection.t -> state -> (state, 'error) handler_result

  val handle_shutdown : Connection.t -> state -> (state, 'error) handler_result
  val handle_timeout : Connection.t -> state -> (state, 'error) handler_result
end

module Default = struct
  let handle_close _sock _state = ()
  let handle_connection _sock state = Continue state
  let handle_data _data _sock state = Continue state
  let handle_error err _sock state = Error (state, err)
  let handle_shutdown _sock _state = Ok
  let handle_timeout _sock _state = Ok
end

type 's t = (module Intf with type state = 's)

let handle_close (type s) (module H : Intf with type state = s) sock (state : s)
    =
  H.handle_close sock state

let handle_connection (type s) (module H : Intf with type state = s) sock
    (state : s) =
  H.handle_connection sock state

let handle_data (type s) (module H : Intf with type state = s) data sock
    (state : s) =
  H.handle_data data sock state
