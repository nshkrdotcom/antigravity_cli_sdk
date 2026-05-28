defmodule AntigravityCliSdk.ModelsTest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.Models

  test "reads the core Antigravity model catalog" do
    assert {:ok, "default"} = Models.default_model()
    assert {:ok, models} = Models.list()
    assert Enum.any?(models, &(&1.id == "default" and &1.default?))
    assert :ok = Models.validate_model("default")
  end
end
