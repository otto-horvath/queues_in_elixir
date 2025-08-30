defmodule StockMonitor do
  def process_name(), do: process_name(self())

  def process_name(pid) do
    [registered_name: name] = Process.info(pid, [:registered_name])
    name
  end

  def sample_setup() do
    {:ok, _o1} = StockMonitor.Observers.new_observer([:BRL])
    {:ok, _o2} = StockMonitor.Observers.new_observer([:BRL, :XYZ])
    {:ok, _o3} = StockMonitor.Observers.new_observer([:NZA, :XYZ])

    StockMonitor.Generator.subscribe(StockQueue)
  end
end
