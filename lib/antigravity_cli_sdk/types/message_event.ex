defmodule AntigravityCliSdk.Types.MessageEvent do
  @moduledoc "Antigravity assistant/user message event."

  @enforce_keys [:role, :content]
  defstruct type: :message,
            role: :assistant,
            content: "",
            delta?: false,
            model: nil,
            metadata: %{},
            raw: %{},
            extra: %{}

  @type role :: :assistant | :user

  @type t :: %__MODULE__{
          type: :message,
          role: role(),
          content: String.t(),
          delta?: boolean(),
          model: String.t() | nil,
          metadata: map(),
          raw: map(),
          extra: map()
        }
end
