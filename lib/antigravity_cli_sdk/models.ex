defmodule AntigravityCliSdk.Models do
  @moduledoc "Antigravity model catalog helpers."

  alias CliSubprocessCore.ModelRegistry

  defmodule Model do
    @moduledoc "Antigravity model entry."
    @enforce_keys [:id]
    defstruct [:id, :label, default?: false]

    @type t :: %__MODULE__{
            id: String.t(),
            label: String.t() | nil,
            default?: boolean()
          }
  end

  @spec list(keyword()) :: {:ok, [Model.t()]} | {:error, term()}
  def list(opts \\ []) do
    with {:ok, ids} <- ModelRegistry.list_visible(:antigravity, opts),
         {:ok, default} <- default_model(opts) do
      {:ok,
       Enum.map(ids, fn id ->
         %Model{id: id, label: id, default?: id == default}
       end)}
    end
  end

  @spec default_model(keyword()) :: {:ok, String.t() | nil} | {:error, term()}
  def default_model(opts \\ []), do: ModelRegistry.default_model(:antigravity, opts)

  @spec validate_model(String.t(), keyword()) :: :ok | {:error, term()}
  def validate_model(model, opts \\ []) when is_binary(model) do
    case ModelRegistry.validate(:antigravity, Keyword.put(opts, :model, model)) do
      {:ok, _model} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
