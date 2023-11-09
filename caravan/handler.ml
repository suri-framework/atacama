type ('state, 'error) handler_result =
  | Ok
  | Continue of 'state
  | Continue_with_timeout of 'state * Riot.Socket.timeout
  | Close of 'state
  | Error of 'state * 'error

module type Intf = sig
  val handle_connection : Socket.t -> 'state -> ('state, 'error) handler_result

  val handle_data :
    Bigstringaf.t -> Socket.t -> 'state -> ('state, 'error) handler_result

  val handle_close : Socket.t -> 'state -> ('state, 'error) handler_result

  val handle_error :
    'error -> Socket.t -> 'state -> ('state, 'error) handler_result

  val handle_shutdown : Socket.t -> 'state -> ('state, 'error) handler_result
  val handle_timeout : Socket.t -> 'state -> ('state, 'error) handler_result
end

module Default : Intf = struct
  let handle_connection _sock state = Continue state
  let handle_data _data _sock state = Continue state
  let handle_close _sock state = Close state
  let handle_error err _sock state = Error (state, err)
  let handle_shutdown _sock _state = Ok
  let handle_timeout _sock _state = Ok
end
