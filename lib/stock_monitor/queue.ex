defmodule StockMonitor.Queue do
  require Logger

  use GenServer

  import StockMonitor

  @impl true
  def init(args) do
    {:ok, args}
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: StockQueue)
  end

  @impl true
  def handle_cast({:push, %{stock: stock, price: price}}, stocks_observers) do
    Logger.info("Queue::received #{stock}:$#{price}")

    stocks_observers
    |> Map.get(stock)
    |> Enum.each(&(post_stock_price(&1, stock, price)))

    {:noreply, stocks_observers}
  end

  @impl true
  def handle_cast({:subscribe, observer, stocks}, stocks_observers) do
    {:noreply, subscribe_observer(stocks_observers, observer, stocks)}
  end

  def subscribe(observer, stocks) do
    GenServer.cast(StockQueue, {:subscribe, observer, stocks})
  end

  defp subscribe_observer(stocks_observers, observer, stocks) do
    stocks
    |> Enum.reduce(stocks_observers, fn stock, subscribers ->
      Logger.info("Queue::Subscribing #{process_name(observer)} to #{stock}")

      Map.update(subscribers, stock, [observer], fn subs -> [observer | subs] end)
    end)
  end

  defp post_stock_price(observer, stock, price), do: GenServer.cast(observer, {:receive, %{stock: stock, price: price}})

end


m1 = StockMonitor.Observer.start_link(:first)
m2 = StockMonitor.Observer.start_link(:second)
m3 = StockMonitor.Observer.start_link(:third)

StockMonitor.Queue.subscribe(m1, [:BRL])
StockMonitor.Queue.subscribe(m2, [:BRL, :XYZ])
StockMonitor.Queue.subscribe(m3, [:NZA, :XYZ])

StockMonitor.Generator.subscribe(StockQueue)
