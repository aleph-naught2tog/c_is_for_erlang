-module(complex_erl).
-export([start/1, stop/0, init/1]).
-export([add_one/1, multiply_by_two/1]).

start(ExternalProgram) ->
  spawn(?MODULE, init, [ExternalProgram]).

stop() ->
  complex ! stop.

init(ExternalProgram) ->
  register(complex, self()),
  process_flag(trap_exit, true),
  Port = open_port({spawn, ExternalProgram}, [{packet, 2}]),
  loop(Port).

add_one(X) ->
  call_port({add_one, X}).

multiply_by_two(Y) ->
  call_port({multiply_by_two, Y}).

call_port(Message) ->
  complex ! {call, self(), Message},
  receive
    {complex, Result} ->
      Result
  end.

loop(Port) ->
  receive
    {call, Caller, Message} ->
      Port ! {self(), {command, encode(Message)}},
      receive
        {Port, {data, Data}} ->
          Caller ! {complex, decode(Data)}
      end,
      loop(Port);

    stop ->
      Port ! {self(), close},
      receive
        {Port, closed} ->
          exit(normal)
      end;

    {'EXIT', Port, _} ->
      exit(port_terminated)
  end.

encode({add_one, Argument}) -> [1, Argument];
encode({multiply_by_two, Argument}) -> [2, Argument].

decode([Int]) -> Int.

