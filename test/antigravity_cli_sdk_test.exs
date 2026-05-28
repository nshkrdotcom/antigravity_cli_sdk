defmodule AntigravityCliSdkTest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.Options

  test "loads the public API and builds options" do
    assert Code.ensure_loaded?(AntigravityCliSdk)
    assert {:ok, %Options{}} = AntigravityCliSdk.create_options(%{})
  end

  test "run/2 returns no_result when a stream produces no assistant text" do
    assert {:error, error} =
             AntigravityCliSdk.run("hello", %Options{cli_command: "/definitely/missing/agy"})

    assert error.kind in [:cli_not_found, :stream_start_failed]
  end
end
