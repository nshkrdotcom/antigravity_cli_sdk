alias AntigravityCliSdk.Types.{MessageEvent, ResultEvent}
alias CliSubprocessCore.{Event, Payload}

{:ok, delta_one} =
  Event.parse(
    kind: :assistant_delta,
    provider: :antigravity,
    payload: Payload.AssistantDelta.new(content: "ANTIGRAVITY_")
  )

{:ok, delta_two} =
  Event.parse(
    kind: :assistant_delta,
    provider: :antigravity,
    payload: Payload.AssistantDelta.new(content: "LINES_OK")
  )

{:ok, result} =
  Event.parse(
    kind: :result,
    provider: :antigravity,
    payload: Payload.Result.new(status: :completed, output: %{})
  )

state = AntigravityCliSdk.Runtime.CLI.new_projection_state()

{[%MessageEvent{content: "ANTIGRAVITY_"}], state} =
  AntigravityCliSdk.Runtime.CLI.project_event(delta_one, state)

{[%MessageEvent{content: "LINES_OK"}], state} =
  AntigravityCliSdk.Runtime.CLI.project_event(delta_two, state)

{[%ResultEvent{result: "ANTIGRAVITY_LINES_OK"}], _state} =
  AntigravityCliSdk.Runtime.CLI.project_event(result, state)

IO.puts("plain_text_projection=ANTIGRAVITY_LINES_OK")
