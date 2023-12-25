-module(echo).
-behaviour(ranch_protocol).
-export([main/1]).
-export([start_link/3]).
-export([init/3]).


main(_) ->
    application:ensure_all_started(ranch),
    Port =2112,
    {ok, _} = ranch:start_listener(tcp_echo,
		ranch_tcp, #{
                 socket_opts => [{port, Port}, {recbuf, 1024 * 50}],
                 num_acceptors =>  100
                },
		echo, []),
    io:format("TCP Echo Server running on port ~p~n", [Port]),
    receive
        stop -> ok
    end.

start_link(Ref, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
	{ok, Pid}.

init(Ref, Transport, _Opts = []) ->
	{ok, Socket} = ranch:handshake(Ref),
	loop(Socket, Transport).

loop(Socket, Transport) ->
	case Transport:recv(Socket, 0, 60000) of
		{ok, Data} ->
			Transport:send(Socket, Data),
			loop(Socket, Transport);
		_ ->
			ok = Transport:close(Socket)
	end.
