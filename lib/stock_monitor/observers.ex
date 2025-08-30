defmodule StockMonitor.Observers do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def new_observer(stocks) do
    DynamicSupervisor.start_child(__MODULE__, {StockMonitor.Observer, stocks})
  end
end
