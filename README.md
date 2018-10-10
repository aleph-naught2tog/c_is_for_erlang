# Linking C and Erlang/Elixir

### Required
* C and a C compiler (you almost definitely have this)
* Erlang

#### Optional
* Elixir (only required to run the Elixir one)

_The source for the code comes from the Erlang Interoperability guide, with tweaks from me, such as clearer variable names, etc._

## Compilation notes

* To compile the C you can run `gcc -o external_program complex_c.c` (or run the local compile shell script, they're the same).

* Erlang allows hot-module-reloading, so if you want to experiment you can mess around in the source code and then just run `c(complex_erl)`    

## Running

### From Erlang/`erl`
To run, you need to use the `erl` shell. You can open it by running `erl` from your command line.

Erlang uses periods (`.`) to end statements; you need to do the same in the shell.
(As you're experimenting, if it seems as if it's ignoring you, ie just keeps giving
you new lines, probably you forgot a closing `.` or didn't close quotes somewhere.)

```
1> c(complex_erl).
%=> {ok,complex_erl}

2> complex_erl:start("./external_program").
%=> <0.83.0>      % or whatever the PID spawned was

3> complex_erl:add_one(5).
%=> 6

4> complex_erl:multiply_by_two(7).
%=> 14

5> complex_erl:stop
```

To exit, you can do <kbd>ctrl-g</kbd> to stop and then type <kbd>q</kbd> to quit.


### From Elixir/`iex`

```
iex(1)> c("complex_ex.ex")
[ComplexEx]
iex(2)> ComplexEx.start("./external_program")
#PID<0.114.0>
iex(3)> ComplexEx.add_one(15)
16
iex(4)> ComplexEx.multiply_by_two(15)
30
iex(5)> ComplexEx.stop()
:stop
```

Instead of <kbd>ctrl-g</kbd> in `erl`, here you want to use <kbd>ctrl-c</kbd> to exit.