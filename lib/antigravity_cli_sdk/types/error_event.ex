defmodule AntigravityCliSdk.Types.ErrorEvent do
  @moduledoc "Antigravity SDK error stream event."

  @enforce_keys [:message]
  defstruct type: :error,
            severity: "fatal",
            message: "",
            code: nil,
            details: nil,
            stderr: nil,
            stderr_truncated?: false,
            metadata: %{},
            raw: %{},
            extra: %{}

  @type t :: %__MODULE__{
          type: :error,
          severity: String.t(),
          message: String.t(),
          code: String.t() | nil,
          details: term(),
          stderr: String.t() | nil,
          stderr_truncated?: boolean(),
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
