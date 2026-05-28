defmodule AntigravityCliSdk.Stream do
  @moduledoc "Lazy streaming execution of Antigravity CLI prompts."

  alias AntigravityCliSdk.{Configuration, Error, Options, Runtime.CLI, Types}
  alias AntigravityCliSdk.Types.ErrorEvent
  alias CliSubprocessCore.Event, as: CoreEvent

  defmodule State do
    @moduledoc false

    @enforce_keys [
      :session,
      :session_ref,
      :session_monitor_ref,
      :session_event_tag,
      :projection_state,
      :receive_timeout_ms
    ]
    defstruct session: nil,
              session_ref: nil,
              session_monitor_ref: nil,
              session_event_tag: nil,
              projection_state: nil,
              done?: false,
              stderr: "",
              stderr_truncated?: false,
              receive_timeout_ms: Configuration.stream_timeout_ms(),
              max_stderr_buffer_bytes: Configuration.max_stderr_buffer_size()
  end

  @spec execute(String.t(), Options.t()) :: Enumerable.t(Types.stream_event())
  def execute(prompt, %Options{} = options \\ %Options{}) when is_binary(prompt) do
    Stream.resource(fn -> start(prompt, options) end, &receive_next/1, &cleanup/1)
  end

  defp start(prompt, %Options{} = options) do
    session_ref = make_ref()

    case CLI.start_session(prompt: prompt, options: options, subscriber: {self(), session_ref}) do
      {:ok, session, %{info: info, projection_state: projection_state}} ->
        session_monitor_ref = Process.monitor(session)

        %State{
          session: session,
          session_ref: session_ref,
          session_monitor_ref: session_monitor_ref,
          session_event_tag: Map.get(info, :session_event_tag, CLI.session_event_tag()),
          projection_state: projection_state,
          receive_timeout_ms: options.timeout_ms,
          max_stderr_buffer_bytes: options.max_stderr_buffer_bytes
        }

      {:error, reason} ->
        {:error, Error.normalize(reason, kind: :stream_start_failed)}
    end
  rescue
    error -> {:error, Error.normalize(error, kind: :stream_start_failed)}
  catch
    :exit, reason -> {:error, Error.normalize(reason, kind: :stream_start_failed)}
  end

  defp receive_next({:error, reason}) do
    {[error_event(reason)], {:halted}}
  end

  defp receive_next({:halted}), do: {:halt, {:halted}}
  defp receive_next(%State{done?: true} = state), do: {:halt, state}

  defp receive_next(%State{} = state) do
    receive do
      {event_tag, ref, {:event, %CoreEvent{} = event}}
      when event_tag == state.session_event_tag and ref == state.session_ref ->
        handle_core_event(event, state)

      {:DOWN, ref, :process, _pid, _reason}
      when ref == state.session_monitor_ref ->
        {:halt, %{state | done?: true}}
    after
      state.receive_timeout_ms ->
        event =
          %ErrorEvent{
            severity: "fatal",
            message:
              "Timed out after #{state.receive_timeout_ms}ms waiting for Antigravity CLI output",
            code: "stream_timeout",
            stderr: normalize_stderr(state.stderr),
            stderr_truncated?: state.stderr_truncated?
          }

        {[event], %{state | done?: true}}
    end
  end

  defp handle_core_event(event, %State{} = state) do
    state = maybe_capture_stderr(state, event)
    {projected, projection_state} = CLI.project_event(event, state.projection_state)
    state = %{state | projection_state: projection_state}

    projected =
      Enum.map(projected, fn
        %ErrorEvent{severity: "fatal"} = error ->
          %{
            error
            | stderr: error.stderr || normalize_stderr(state.stderr),
              stderr_truncated?: state.stderr_truncated?
          }

        other ->
          other
      end)

    cond do
      projected == [] ->
        receive_next(state)

      Enum.any?(projected, &Types.final_event?/1) ->
        {projected, %{state | done?: true}}

      true ->
        {projected, state}
    end
  end

  defp maybe_capture_stderr(%State{} = state, %CoreEvent{} = event) do
    case CLI.stderr_chunk(event) do
      chunk when is_binary(chunk) ->
        {stderr, truncated?} =
          append_stderr_tail(
            state.stderr,
            chunk,
            state.max_stderr_buffer_bytes,
            state.stderr_truncated?
          )

        %{state | stderr: stderr, stderr_truncated?: truncated?}

      _other ->
        state
    end
  end

  defp append_stderr_tail(_existing, _data, max_size, _already_truncated?)
       when not is_integer(max_size) or max_size <= 0,
       do: {"", true}

  defp append_stderr_tail(existing, data, max_size, already_truncated?) do
    combined = existing <> data

    if byte_size(combined) <= max_size do
      {combined, already_truncated?}
    else
      {String.slice(combined, -max_size, max_size), true}
    end
  end

  defp cleanup(%State{} = state) do
    Process.demonitor(state.session_monitor_ref, [:flush])
    _ = CLI.close(state.session)
    :ok
  end

  defp cleanup(_state), do: :ok

  defp error_event(%Error{} = error) do
    %ErrorEvent{
      severity: "fatal",
      message: error.message,
      code: Atom.to_string(error.kind),
      details: error.details
    }
  end

  defp normalize_stderr(""), do: nil
  defp normalize_stderr(stderr), do: stderr
end
