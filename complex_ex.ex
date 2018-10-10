defmodule ComplexEx do
  def start(external_program) do
    spawn(__MODULE__, :init, [external_program])
  end

  def stop do
    send(:complex, :stop)
  end

  def init(external_program) do
    Process.register(self(), :complex)
    Process.flag(:trap_exit, true)
    port = Port.open({:spawn, external_program}, [{:packet, 2}])
    loop(port)
  end

  def add_one(argument) do
    call_port({:add_one, argument})
  end

  def multiply_by_two(argument) do
    call_port({:multiply_by_two, argument})
  end

  def call_port(message) do
    send(:complex, {:call, self(), message})
    receive do
      {:complex, result} -> result
    end
  end

  def loop(port) do
    receive do
      {:call, caller, message} ->
        send(port, {self(), {:command, encode(message)}})
        receive do
          {^port, {:data, data}} ->
            send(caller, {:complex, decode(data)})
        end
        loop(port)

      :stop ->
        send(port, {self(), :close})
        receive do
          {^port, :closed} -> exit(:normal)
        end

      {:EXIT, ^port, _} ->
        exit(:port_terminated)
    end
  end

  def encode({:add_one, argument}), do: [1, argument]
  def encode({:multiply_by_two, argument}), do: [2, argument]

  def decode([int]), do: int
end
