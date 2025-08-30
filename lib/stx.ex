defmodule Stx do
  def process_name(), do: process_name(self())

  def process_name(pid) do
    [registered_name: name] = Process.info(pid, [:registered_name])
    name
  end

  def sample_setup() do
    {:ok, _o1} = Stx.Observer.subscribe([:BRL])
    {:ok, _o2} = Stx.Observer.subscribe([:BRL, :XYZ])
    {:ok, _o3} = Stx.Observer.subscribe([:NZA, :XYZ])
  end
end
