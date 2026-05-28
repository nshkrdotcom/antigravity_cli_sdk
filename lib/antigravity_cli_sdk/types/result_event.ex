defmodule AntigravityCliSdk.Types.ResultEvent do
  @moduledoc "Antigravity final result event."

  @enforce_keys [:status]
  defstruct type: :result,
            status: :completed,
            stop_reason: nil,
            result: nil,
            usage: %{},
            duration_ms: nil,
            metadata: %{},
            raw: %{},
            extra: %{}

  @type t :: %__MODULE__{
          type: :result,
          status: :completed | :error,
          stop_reason: term(),
          result: String.t() | nil,
          usage: map(),
          duration_ms: non_neg_integer() | nil,
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
