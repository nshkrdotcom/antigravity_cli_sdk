defmodule AntigravityCliSdk.Types.ResultEvent do
  @moduledoc "Antigravity final result event."

  @enforce_keys [:status]
  defstruct type: :result,
            status: :completed,
            stop_reason: nil,
            result: nil,
            object: nil,
            provider_session_id: nil,
            output: nil,
            usage: %{},
            duration_ms: nil,
            metadata: %{},
            raw: %{},
            extra: %{}

  @type t :: %__MODULE__{
          type: :result,
          status: term(),
          stop_reason: term(),
          result: String.t() | nil,
          object: term(),
          provider_session_id: String.t() | nil,
          output: term(),
          usage: map(),
          duration_ms: non_neg_integer() | nil,
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
