defmodule AntigravityCliSdkTest do
  use ExUnit.Case
  doctest AntigravityCliSdk

  test "loads the application namespace" do
    assert Code.ensure_loaded?(AntigravityCliSdk)
    assert Code.ensure_loaded?(AntigravityCliSdk.Application)
  end
end
