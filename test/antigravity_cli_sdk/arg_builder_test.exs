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
          model: "gemini-3.8-flash",
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
             "--model",
             "gemini-3.8-flash",
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

  test "forwards non-default model and omits default or empty model" do
    assert ArgBuilder.build_args(%Options{model: "gemini-3.8-flash"}, "hi") == [
             "--print",
             "hi",
             "--model",
             "gemini-3.8-flash"
           ]

    assert ArgBuilder.build_args(%Options{model: "default"}, "hi") == ["--print", "hi"]
    assert ArgBuilder.build_args(%Options{model: ""}, "hi") == ["--print", "hi"]
    assert ArgBuilder.build_args(%Options{model: nil}, "hi") == ["--print", "hi"]
  end

  test "forwards effort option and model_payload reasoning" do
    assert ArgBuilder.build_args(%Options{model: "gemini-3.8-flash", effort: "high"}, "hi") == [
             "--print",
             "hi",
             "--model",
             "gemini-3.8-flash",
             "--effort",
             "high"
           ]

    assert ArgBuilder.build_args(%Options{effort: :low}, "hi") == [
             "--print",
             "hi",
             "--effort",
             "low"
           ]

    assert ArgBuilder.build_args(
             %Options{
               model: "gemini-3.8-flash",
               model_payload: %{reasoning: "medium"}
             },
             "hi"
           ) == [
             "--print",
             "hi",
             "--model",
             "gemini-3.8-flash",
             "--effort",
             "medium"
           ]

    assert ArgBuilder.build_args(%Options{model: "default", effort: "high"}, "hi") == [
             "--print",
             "hi",
             "--effort",
             "high"
           ]

    assert ArgBuilder.build_args(%Options{effort: nil}, "hi") == ["--print", "hi"]
    assert ArgBuilder.build_args(%Options{effort: ""}, "hi") == ["--print", "hi"]
  end
end
