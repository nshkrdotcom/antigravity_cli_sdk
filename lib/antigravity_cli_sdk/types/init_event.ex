defmodule AntigravityCliSdk.Types.InitEvent do
  @moduledoc "Antigravity stream initialization event."

  @enforce_keys [:raw]
  defstruct type: :init, session_id: nil, model: nil, cwd: nil, raw: %{}, extra: %{}

  @type t :: %__MODULE__{
          type: :init,
          session_id: String.t() | nil,
          model: String.t() | nil,
          cwd: String.t() | nil,
          raw: map(),
          extra: map()
        }
end
