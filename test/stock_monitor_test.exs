defmodule StockMonitorTest do
  use ExUnit.Case
  doctest StockMonitor

  test "greets the world" do
    assert StockMonitor.hello() == :world
  end
end
