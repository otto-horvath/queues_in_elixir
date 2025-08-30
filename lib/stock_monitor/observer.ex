defmodule StockMonitor.Observer do
  require Logger
  use GenServer
  import StockMonitor

  def start_link(stocks) do

    stocks_names = stocks |> Enum.map(&Atom.to_string/1) |> Enum.join("_")
    name = "observer_#{stocks_names}_#{random_id()}" |> String.to_atom()

    GenServer.start_link(__MODULE__, stocks, name: name)
  end

  @impl true
  def init(stocks) do
    {:ok, stocks, {:continue, :subscribe}}
  end

  @impl true
  def handle_continue(:subscribe, stocks) do
    Process.flag(:trap_exit, true)
    StockMonitor.Queue.subscribe(self(), stocks)
    {:noreply, stocks}
  end

  @impl true
  def handle_cast({:receive, %{stock: stock, price: price}}, _state) do
    Logger.info("Observer #{process_name()}::received #{stock}:$#{price}")

    {:noreply, []}
  end

  @impl true
  def handle_cast(:simulate_kill, _state) do
    raise ">> Killing #{process_name()}"
  end

  def simulate_kill(observer) do
    GenServer.cast(observer, :simulate_kill)
  end

  @impl true
  def terminate(_reason, _state) do
    StockMonitor.Queue.unsubscribe(self())
  end

  defp random_id(), do: :crypto.strong_rand_bytes(16) |> Base.encode16() |> String.slice(0..3)
end
