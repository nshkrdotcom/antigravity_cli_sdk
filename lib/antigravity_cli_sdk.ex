defmodule AntigravityCliSdk do
  @moduledoc """
  Elixir SDK for the Google Antigravity CLI (`agy`).

  The primary API is `execute/2` for typed streaming events and `run/2` for a
  one-shot text result. The SDK delegates process execution to
  `cli_subprocess_core` and uses the same Antigravity provider profile as
  `agent_session_manager`.
  """

  alias AntigravityCliSdk.{Error, Options, Stream}
  alias AntigravityCliSdk.Runtime.CLI, as: RuntimeCLI
  alias AntigravityCliSdk.Types.{ErrorEvent, MessageEvent, ResultEvent}

  @type event :: AntigravityCliSdk.Types.stream_event()

  @doc """
  Starts a supervised SDK session.
  """
  @spec start_session(keyword()) ::
          {:ok, pid(), %{info: map(), projection_state: map(), temp_dir: String.t() | nil}}
          | {:error, term()}
  defdelegate start_session(opts), to: RuntimeCLI

  @doc """
  Streams typed Antigravity events for one prompt.
  """
  @spec execute(String.t(), Options.t()) :: Enumerable.t(event())
  def execute(prompt, %Options{} = options \\ %Options{}) when is_binary(prompt) do
    Stream.execute(prompt, options)
  end

  @doc """
  Executes one prompt and returns the completed assistant text.
  """
  @spec run(String.t(), Options.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def run(prompt, %Options{} = options \\ %Options{}) when is_binary(prompt) do
    prompt
    |> execute(options)
    |> Enum.reduce({:ok, ""}, fn
      %MessageEvent{role: :assistant, content: content}, {:ok, acc} ->
        {:ok, acc <> (content || "")}

      %ResultEvent{status: :completed, result: result}, {:ok, ""} when is_binary(result) ->
        {:ok, result}

      %ResultEvent{status: :completed}, acc ->
        acc

      %ErrorEvent{} = event, _acc ->
        {:error,
         Error.new(
           kind: event.code || :execution_failed,
           message: event.message,
           details: event.stderr || event.details
         )}

      _event, acc ->
        acc
    end)
    |> case do
      {:ok, ""} -> {:error, Error.new(kind: :no_result, message: "No result received from agy")}
      other -> other
    end
  end

  @doc """
  Alias for `run/2`, provided for ASM runtime-kit symmetry.
  """
  @spec execute_text(String.t(), Options.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def execute_text(prompt, %Options{} = options \\ %Options{}), do: run(prompt, options)

  @doc """
  Lists known Antigravity provider sessions.

  The current `agy --print` surface does not expose a portable session-list
  command, so this returns an empty list while preserving the SDK contract.
  """
  @spec list_provider_sessions(keyword()) :: {:ok, [term()]} | {:error, Error.t()}
  defdelegate list_provider_sessions(opts \\ []), to: AntigravityCliSdk.Session

  @doc """
  Builds and validates an `%AntigravityCliSdk.Options{}` struct.
  """
  @spec create_options(keyword() | map() | Options.t()) :: {:ok, Options.t()} | {:error, term()}
  defdelegate create_options(attrs), to: Options, as: :new
end
