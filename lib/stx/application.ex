defmodule Stx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Stx.Queue, %{}},
      {Stx.Generator, %{interval: 750, stocks: [:XYZ, :BRL, :NZA]}},
      {Stx.ObserversSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Stx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
