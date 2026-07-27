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

  test "provider result text wins and all Core result fields survive projection" do
    delta = event!(:assistant_delta, Payload.AssistantDelta.new(content: "fallback"))

    result =
      event!(
        :result,
        Payload.Result.new(
          status: :error,
          stop_reason: "provider_error",
          output: %{
            result: "provider result",
            usage: %{input_tokens: 2, output_tokens: 3},
            duration_ms: 41
          },
          object: nil,
          metadata: %{source: :provider},
          future_field: "preserved"
        ),
        provider_session_id: "agy-session-7",
        raw: %{provider: "raw"}
      )

    {[_message], state} = CLI.project_event(delta, CLI.new_projection_state())

    assert {[%ResultEvent{} = projected], _state} = CLI.project_event(result, state)
    assert projected.result == "provider result"
    assert projected.status == :error
    assert projected.stop_reason == "provider_error"
    assert projected.object == nil
    assert projected.provider_session_id == "agy-session-7"
    assert projected.output.result == "provider result"
    assert projected.usage == %{input_tokens: 2, output_tokens: 3}
    assert projected.duration_ms == 41
    assert projected.metadata == %{source: :provider}
    assert projected.raw == %{provider: "raw"}
    assert projected.extra == %{future_field: "preserved"}
  end

  defp event!(kind, payload, opts \\ []) do
    {:ok, event} =
      Event.parse(
        kind: kind,
        provider: :antigravity,
        payload: payload,
        provider_session_id: Keyword.get(opts, :provider_session_id),
        raw: Keyword.get(opts, :raw)
      )

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
