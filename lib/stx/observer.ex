defmodule Stx.Observer do
  require Logger
  use GenServer
  import Stx

  def subscribe(stocks) do
    DynamicSupervisor.start_child(Stx.ObserversSupervisor, {Stx.Observer, stocks})
  end

  def start_link(stocks) do
    GenServer.start_link(__MODULE__, stocks, name: generate_name(stocks))
  end

  @impl true
  def init(stocks) do
    {:ok, stocks, {:continue, :subscribe}}
  end

  @impl true
  def handle_continue(:subscribe, stocks) do
    Process.flag(:trap_exit, true)
    Stx.Queue.subscribe(self(), stocks)
    {:noreply, stocks}
  end

  @impl true
  def handle_cast({:notify, %{stock: stock, price: price}}, _state) do
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
    Stx.Queue.unsubscribe(self())
  end

  defp generate_name(stocks), do: "observer.#{random_id()}.#{stocks_names(stocks)}" |> String.to_atom()

  defp random_id(), do: :crypto.strong_rand_bytes(16) |> Base.encode16() |> String.slice(0..3)

  defp stocks_names(stocks), do: stocks |> Enum.map(&Atom.to_string/1) |> Enum.join("_")
end
