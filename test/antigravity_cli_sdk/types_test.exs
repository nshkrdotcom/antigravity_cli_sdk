defmodule AntigravityCliSdk.TypesTest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.Types.MessageEvent

  test "parse_event/1 projects plain Antigravity stdout into assistant message events" do
    assert {:ok, [%MessageEvent{role: :assistant, content: "hello", delta?: true}]} =
             AntigravityCliSdk.Types.parse_event("hello")

    assert {:ok, []} = AntigravityCliSdk.Types.parse_event("   ")
  end
end
