defmodule AntigravityCliSdk.Runtime.CLITest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.{Options, Runtime.CLI}
  alias AntigravityCliSdk.Types.{MessageEvent, ResultEvent}
  alias CliSubprocessCore.{Event, Payload}

  test "render_for_test/1 exposes normalized invocation details" do
    path = executable_fixture!("agy-render")

    assert {:ok, rendered} =
             CLI.render_for_test(
               prompt: "Hi",
               options: %Options{
                 cli_command: path,
                 cwd: "/tmp/work",
                 api_key: "secret",
                 sandbox: true,
                 dangerously_skip_permissions: true,
                 add_dirs: ["/repo"]
               }
             )

    assert rendered.provider == :antigravity
    assert rendered.cwd == "/tmp/work"
    assert rendered.env["ANTIGRAVITY_API_KEY"] == "secret"
    assert "--dangerously-skip-permissions" in rendered.args
    assert "--add-dir" in rendered.args
    refute "secret" in rendered.args
  end

  test "start_session/1 rejects untagged subscribers" do
    assert {:error, %ArgumentError{} = error} =
             CLI.start_session(
               prompt: "Hi",
               options: %Options{cli_command: executable_fixture!("agy-subscriber")},
               subscriber: self()
             )

    assert Exception.message(error) =~ "subscriber must be a tagged {pid, reference()} tuple"
  end

  test "project_event/2 accumulates assistant deltas into the final result" do
    delta = event!(:assistant_delta, Payload.AssistantDelta.new(content: "OK"))
    result = event!(:result, Payload.Result.new(status: :completed, output: %{}))

    {[%MessageEvent{content: "OK"}], state} = CLI.project_event(delta, CLI.new_projection_state())
    {[%ResultEvent{result: "OK"}], state} = CLI.project_event(result, state)

    assert {[], ^state} = CLI.project_event(result, state)
  end

  defp event!(kind, payload) do
    {:ok, event} = Event.parse(kind: kind, provider: :antigravity, payload: payload)
    event
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
