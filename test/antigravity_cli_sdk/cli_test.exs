defmodule AntigravityCliSdk.CLITest do
  use ExUnit.Case, async: false

  alias AntigravityCliSdk.{CLI, Options}
  alias AntigravityCliSdk.Error

  setup do
    original_cli_path = Application.get_env(:antigravity_cli_sdk, :cli_path)

    on_exit(fn ->
      case original_cli_path do
        nil -> Application.delete_env(:antigravity_cli_sdk, :cli_path)
        value -> Application.put_env(:antigravity_cli_sdk, :cli_path, value)
      end
    end)

    :ok
  end

  test "resolves a configured CLI path from application env" do
    path = executable_fixture!("agy-fixture")
    Application.put_env(:antigravity_cli_sdk, :cli_path, path)

    assert {:ok, spec} = CLI.resolve()
    assert spec.program == path
  end

  test "build_invocation keeps credentials out of argv and in env" do
    path = executable_fixture!("agy-fixture")

    assert {:ok, invocation} =
             CLI.build_invocation(
               prompt: "hello",
               options: %Options{
                 cli_command: path,
                 api_key: "secret",
                 dangerously_skip_permissions: true
               }
             )

    assert invocation.args == ["--print", "hello", "--dangerously-skip-permissions"]
    assert invocation.env["ANTIGRAVITY_API_KEY"] == "secret"
    refute "secret" in invocation.args
  end

  test "common unsupported intents fail before CLI resolution" do
    for options <- [
          %Options{cli_command: "/missing/agy", completion_only: true},
          %Options{
            cli_command: "/missing/agy",
            output_schema: %{"type" => "object"}
          }
        ] do
      assert {:error,
              %Error{
                kind: :unsupported_capability,
                context: %{
                  provider: :antigravity,
                  support_state: :unsupported
                }
              }} = CLI.build_invocation(prompt: "hello", options: options)
    end
  end

  test "session options keep idle, total, and orphan-reap timeouts separate" do
    options = %Options{
      timeout_ms: 60_000,
      run_deadline_ms: 120_000,
      transport_headless_timeout_ms: 1_234
    }

    session_options = CLI.build_session_options("hello", options)

    assert session_options[:transport_headless_timeout_ms] == 1_234
    refute Keyword.has_key?(session_options, :headless_timeout_ms)
  end

  defp executable_fixture!(name) do
    path =
      Path.join(
        System.tmp_dir!(),
        name <> "-" <> Integer.to_string(System.unique_integer([:positive]))
      )

    File.write!(path, "#!/bin/sh\nexit 0\n")
    File.chmod!(path, 0o755)
    path
  end
end
