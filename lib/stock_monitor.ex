defmodule StockMonitor do
  def process_name(), do: process_name(self())

  def process_name(pid) do
    [registered_name: name] = Process.info(pid, [:registered_name])
    name
  end
end
