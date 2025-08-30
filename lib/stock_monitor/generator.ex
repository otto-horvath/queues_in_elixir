defmodule StockMonitor.Generator do
  require Logger
  use GenServer

  @impl true
  def init(args) do
    {:ok, args, {:continue, :schedule_next_run}}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def handle_continue(:schedule_next_run, %{interval: interval} = state) do
    Process.send_after(self(), :generate_stock, interval)

    {:noreply, state}
  end

  @impl true
  def handle_info(:generate_stock, %{subscribers: subscribers, stocks: stocks} = state) do
    price = :rand.uniform(100000) / 100.0
      |> Float.ceil(2)

    stock = Enum.random(stocks)

    Logger.info("Generator::stock generated #{stock}:$#{price}")

    subscribers
    |> Enum.each(&(GenServer.cast(&1, {:push, %{stock: stock, price: price}})))

    {:noreply, state, {:continue, :schedule_next_run}}
  end

  def subscribe(monitor) do
    GenServer.cast(__MODULE__, {:subscribe, monitor})
  end

  @impl true
  def handle_cast({:subscribe, monitor}, %{subscribers: subscribers} = state) do
    {:noreply, %{state | subscribers: [monitor | subscribers]}}
  end
end
