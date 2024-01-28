open Riot

module rec R : sig
  type t =
    | H : {
        handler :
          (module R.Intf with type state = 'new_state and type error = 'error);
        state : 'new_state;
      }
        -> t

  type ('state, 'error) handler_result =
    | Ok
    | Continue of 'state
    | Continue_with_timeout of 'state * Timeout.t
    | Close of 'state
    | Error of 'state * 'error
    | Switch of t

  module type Intf = sig
    type state
    type error

    val pp_err : Format.formatter -> error -> unit
    val handle_close : Connection.t -> state -> unit

    val handle_connection :
      Connection.t -> state -> (state, error) handler_result

    val handle_data :
      Bytestring.t -> Connection.t -> state -> (state, error) handler_result

    val handle_error :
      error -> Connection.t -> state -> (state, error) handler_result

    val handle_shutdown : Connection.t -> state -> (state, error) handler_result
    val handle_timeout : Connection.t -> state -> (state, error) handler_result

    val handle_message :
      Message.t -> Connection.t -> state -> (state, error) handler_result
  end
end = struct
  type t =
    | H : {
        handler :
          (module R.Intf with type state = 'new_state and type error = 'error);
        state : 'new_state;
      }
        -> t

  type ('state, 'error) handler_result =
    | Ok
    | Continue of 'state
    | Continue_with_timeout of 'state * Timeout.t
    | Close of 'state
    | Error of 'state * 'error
    | Switch of t

  module type Intf = sig
    type state
    type error

    val pp_err : Format.formatter -> error -> unit
    val handle_close : Connection.t -> state -> unit

    val handle_connection :
      Connection.t -> state -> (state, error) handler_result

    val handle_data :
      Bytestring.t -> Connection.t -> state -> (state, error) handler_result

    val handle_error :
      error -> Connection.t -> state -> (state, error) handler_result

    val handle_shutdown : Connection.t -> state -> (state, error) handler_result
    val handle_timeout : Connection.t -> state -> (state, error) handler_result

    val handle_message :
      Message.t -> Connection.t -> state -> (state, error) handler_result
  end
end

include R

module Default = struct
  let pp_err _fmt _err = ()
  let handle_close _sock _state = ()
  let handle_connection _sock state = Continue state
  let handle_data _data _sock state = Continue state
  let handle_error err _sock state = Error (state, err)
  let handle_shutdown _sock _state = Ok
  let handle_timeout _sock _state = Ok
  let handle_message _msg _conn state = Continue state
end

let pp_err (type s e) (module H : Intf with type state = s and type error = e)
    fmt (e : e) =
  H.pp_err fmt e

let handle_close (type s e)
    (module H : Intf with type state = s and type error = e) sock (state : s) =
  H.handle_close sock state

let handle_connection (type s e)
    (module H : Intf with type state = s and type error = e) sock (state : s) =
  H.handle_connection sock state

let handle_data (type s e)
    (module H : Intf with type state = s and type error = e) data sock
    (state : s) =
  H.handle_data data sock state

let handle_message (type s e)
    (module H : Intf with type state = s and type error = e) data conn
    (state : s) =
  H.handle_message data conn state
