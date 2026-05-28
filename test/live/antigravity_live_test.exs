defmodule AntigravityCliSdk.LiveTest do
  use ExUnit.Case, async: false

  alias AntigravityCliSdk.Options
  alias AntigravityCliSdk.Types.ResultEvent

  @moduletag :live
  @moduletag :antigravity
  @moduletag timeout: 180_000

  test "real agy streams and returns exact text" do
    events =
      "Reply with exactly: ANTIGRAVITY_SDK_LIVE_OK"
      |> AntigravityCliSdk.execute(%Options{
        dangerously_skip_permissions: true,
        timeout_ms: 120_000
      })
      |> Enum.to_list()

    assert Enum.any?(events, &match?(%ResultEvent{result: "ANTIGRAVITY_SDK_LIVE_OK"}, &1))
  end
end
