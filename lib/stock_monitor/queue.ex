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
    |> Map.get(stock, [])
    |> Enum.each(&(post_stock_price(&1, stock, price)))

    {:noreply, stocks_observers}
  end

  @impl true
  def handle_cast({:subscribe, observer, stocks}, stocks_observers) do
    {:noreply, subscribe_observer(stocks_observers, observer, stocks)}
  end

  @impl true
  def handle_cast({:unsubscribe, observer}, stocks_observers) do
    updated_observers = stocks_observers
      |> Map.keys()
      |> Enum.reduce(stocks_observers, fn stock, subscribers ->
        Map.update!(subscribers, stock, &( List.delete(&1, observer) ))
      end)

    {:noreply, updated_observers}
  end


  @impl true
  def handle_cast(:inspect, state) do
    IO.inspect(state)

    {:noreply, state}
  end

  def inspect(), do: GenServer.cast(StockQueue, :inspect)

  def subscribe(observer, stocks) do
    GenServer.cast(StockQueue, {:subscribe, observer, stocks})
  end

  def unsubscribe(observer), do: GenServer.cast(StockQueue, {:unsubscribe, observer})

  defp subscribe_observer(stocks_observers, observer, stocks) do
    stocks
    |> Enum.reduce(stocks_observers, fn stock, subscribers ->
      Logger.info("Queue::Subscribing #{process_name(observer)} to #{stock}")

      Map.update(subscribers, stock, [observer], fn subs -> [observer | subs] end)
    end)
  end

  defp post_stock_price(observer, stock, price) do
    GenServer.cast(observer, {:receive, %{stock: stock, price: price}})
  end

end
