defmodule AntigravityCliSdk.ArgBuilderTest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.{ArgBuilder, Options}

  test "builds the required print prompt shape" do
    assert ArgBuilder.build_args(%Options{}, "hello") == ["--print", "hello"]
  end

  test "renders every supported agy flag" do
    args =
      ArgBuilder.build_args(
        %Options{
          sandbox: true,
          dangerously_skip_permissions: true,
          conversation: "conv-1",
          continue: true,
          add_dirs: ["/repo/a", " ", "/repo/b"],
          print_timeout: "30s",
          log_file: "/tmp/agy.log"
        },
        "hello"
      )

    assert args == [
             "--print",
             "hello",
             "--sandbox",
             "--dangerously-skip-permissions",
             "--conversation",
             "conv-1",
             "--continue",
             "--add-dir",
             "/repo/a",
             "--add-dir",
             "/repo/b",
             "--print-timeout",
             "30s",
             "--log-file",
             "/tmp/agy.log"
           ]
  end
end
