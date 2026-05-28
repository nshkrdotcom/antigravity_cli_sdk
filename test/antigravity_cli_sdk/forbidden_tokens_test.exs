defmodule AntigravityCliSdk.ForbiddenTokensTest do
  use ExUnit.Case, async: true

  test "library code does not read OS env directly or atomize external strings" do
    for path <- Path.wildcard("lib/**/*.ex") do
      source = File.read!(path)

      refute source =~ "System.get_env"
      refute source =~ "String.to_atom"
      refute source =~ "String.to_existing_atom"
    end
  end
end
