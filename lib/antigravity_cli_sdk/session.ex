defmodule AntigravityCliSdk.Session do
  @moduledoc "Antigravity session helpers."

  alias AntigravityCliSdk.{Options, Stream}

  defmodule Entry do
    @moduledoc "Structured Antigravity provider session entry."

    @enforce_keys [:id]
    defstruct [:id, :label, :updated_at, raw_line: nil]

    @type t :: %__MODULE__{
            id: String.t(),
            label: String.t() | nil,
            updated_at: String.t() | nil,
            raw_line: String.t() | nil
          }
  end

  @spec list_provider_sessions(keyword()) ::
          {:ok, [Entry.t()]} | {:error, AntigravityCliSdk.Error.t()}
  def list_provider_sessions(_opts \\ []) do
    {:ok, []}
  end

  @spec resume_session(String.t(), Options.t(), String.t()) ::
          Enumerable.t(AntigravityCliSdk.Types.stream_event())
  def resume_session(session_id, %Options{} = opts \\ %Options{}, prompt \\ "")
      when is_binary(session_id) and is_binary(prompt) do
    Stream.execute(prompt, %{opts | conversation: session_id})
  end

  @spec continue_latest(Options.t(), String.t()) ::
          Enumerable.t(AntigravityCliSdk.Types.stream_event())
  def continue_latest(%Options{} = opts \\ %Options{}, prompt \\ "") when is_binary(prompt) do
    Stream.execute(prompt, %{opts | continue: true})
  end
end
