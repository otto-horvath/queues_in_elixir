defmodule StockMonitor.Observer do
  require Logger
  use GenServer
  import StockMonitor

  def start_link(name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: name)

    pid
  end

  @impl true
  def init(_args) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:receive, %{stock: stock, price: price}}, _state) do
    Logger.info("Monitor #{process_name()}::received #{stock}:$#{price}")

    {:noreply, []}
  end
end
