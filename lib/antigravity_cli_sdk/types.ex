defmodule AntigravityCliSdk.Types do
  @moduledoc "Type projection for Antigravity core events."

  alias AntigravityCliSdk.Error
  alias CliSubprocessCore.Event, as: CoreEvent
  alias CliSubprocessCore.Payload
  alias CliSubprocessCore.ProviderProfiles.Antigravity, as: CoreAntigravity

  alias __MODULE__.{
    ErrorEvent,
    InitEvent,
    MessageEvent,
    ResultEvent
  }

  @type stream_event ::
          InitEvent.t()
          | MessageEvent.t()
          | ErrorEvent.t()
          | ResultEvent.t()

  @spec parse_event(String.t()) :: {:ok, [stream_event()]} | {:error, Error.t()}
  def parse_event(line) when is_binary(line) do
    {events, _state} = CoreAntigravity.decode_stdout(line, CoreAntigravity.init_parser_state([]))
    {:ok, Enum.flat_map(events, &project_core_event/1)}
  rescue
    error -> {:error, Error.normalize(error, kind: :parse_error)}
  end

  @spec project_core_event(CoreEvent.t()) :: [stream_event()]
  def project_core_event(%CoreEvent{
        kind: :run_started,
        payload: %Payload.RunStarted{} = payload,
        raw: raw
      }) do
    [
      %InitEvent{
        session_id: payload.provider_session_id,
        cwd: payload.cwd,
        raw: normalize_raw(raw),
        extra: %{command: payload.command, args: payload.args}
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :assistant_delta,
        payload: %Payload.AssistantDelta{} = payload,
        raw: raw
      }) do
    [
      %MessageEvent{
        role: :assistant,
        content: payload.content || "",
        delta?: true,
        metadata: payload.metadata,
        raw: normalize_raw(raw)
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :assistant_message,
        payload: %Payload.AssistantMessage{} = payload,
        raw: raw
      }) do
    [
      %MessageEvent{
        role: :assistant,
        content: content_text(payload.content),
        model: payload.model,
        metadata: payload.metadata,
        raw: normalize_raw(raw)
      }
    ]
  end

  def project_core_event(%CoreEvent{
        kind: :result,
        payload: %Payload.Result{} = payload,
        raw: raw
      }) do
    output = normalize_map(payload.output)

    [
      %ResultEvent{
        status: payload.status,
        stop_reason: payload.stop_reason,
        result: Map.get(output, :result, Map.get(output, "result")),
        usage: normalize_map(Map.get(output, :usage, Map.get(output, "usage", %{}))),
        duration_ms: Map.get(output, :duration_ms, Map.get(output, "duration_ms")),
        metadata: payload.metadata,
        raw: normalize_raw(raw)
      }
    ]
  end

  def project_core_event(%CoreEvent{kind: :error, payload: %Payload.Error{} = payload, raw: raw}) do
    [
      %ErrorEvent{
        severity: Atom.to_string(payload.severity || :error),
        message: payload.message,
        code: payload.code,
        metadata: payload.metadata,
        raw: normalize_raw(raw)
      }
    ]
  end

  def project_core_event(_event), do: []

  @spec final_event?(stream_event()) :: boolean()
  def final_event?(%ResultEvent{}), do: true
  def final_event?(%ErrorEvent{severity: "fatal"}), do: true
  def final_event?(_event), do: false

  defp content_text(content) when is_list(content) do
    Enum.map_join(content, "", fn
      %{"type" => "text", "text" => text} when is_binary(text) -> text
      %{type: "text", text: text} when is_binary(text) -> text
      value when is_binary(value) -> value
      _other -> ""
    end)
  end

  defp content_text(content) when is_binary(content), do: content
  defp content_text(_content), do: ""

  defp normalize_map(%{} = map), do: map
  defp normalize_map(_value), do: %{}

  defp normalize_raw(%{} = raw), do: raw
  defp normalize_raw(nil), do: %{}
  defp normalize_raw(raw), do: %{value: raw}
end
