open Riot

type ('state, 'error) handler_result =
  | Ok
  | Continue of 'state
  | Continue_with_timeout of 'state * Net.Socket.timeout
  | Close of 'state
  | Error of 'state * 'error

module type Intf = sig
  type state

  val handle_close : Socket.t -> state -> (state, 'error) handler_result
  val handle_connection : Socket.t -> state -> (state, 'error) handler_result

  val handle_data :
    Bigstringaf.t -> Socket.t -> state -> (state, 'error) handler_result

  val handle_error :
    'error -> Socket.t -> state -> (state, 'error) handler_result

  val handle_shutdown : Socket.t -> state -> (state, 'error) handler_result
  val handle_timeout : Socket.t -> state -> (state, 'error) handler_result
end

module Default = struct
  let handle_close _sock state = Close state
  let handle_connection _sock state = Continue state
  let handle_data _data _sock state = Continue state
  let handle_error err _sock state = Error (state, err)
  let handle_shutdown _sock _state = Ok
  let handle_timeout _sock _state = Ok
end

type 's t = (module Intf with type state = 's)

let handle_connection (type s) (module H : Intf with type state = s) sock
    (state : s) =
  H.handle_connection sock state

let handle_data (type s) (module H : Intf with type state = s) data sock
    (state : s) =
  H.handle_data data sock state
