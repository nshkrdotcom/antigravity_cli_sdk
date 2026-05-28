defmodule AntigravityCliSdk.Error do
  @moduledoc "Unified error type for Antigravity CLI SDK operations."

  alias CliSubprocessCore.ProviderCLI.ErrorRuntimeFailure
  alias CliSubprocessCore.TransportError, as: CoreTransportError

  @enforce_keys [:kind, :message]
  defexception [:kind, :message, :cause, :details, :context, :exit_code]

  @type kind ::
          :auth_error
          | :cli_not_found
          | :command_execution_failed
          | :config_invalid
          | :execution_failed
          | :input_error
          | :no_result
          | :parse_error
          | :stream_start_failed
          | :stream_timeout
          | :transport_error
          | :transport_exit
          | :user_cancelled
          | :unknown

  @type t :: %__MODULE__{
          kind: kind() | atom(),
          message: String.t(),
          cause: term(),
          details: String.t() | nil,
          context: map() | nil,
          exit_code: integer() | nil
        }

  @kind_aliases %{
    "auth_error" => :auth_error,
    "cli_not_found" => :cli_not_found,
    "command_execution_failed" => :command_execution_failed,
    "config_invalid" => :config_invalid,
    "execution_failed" => :execution_failed,
    "input_error" => :input_error,
    "no_result" => :no_result,
    "parse_error" => :parse_error,
    "stream_start_failed" => :stream_start_failed,
    "stream_timeout" => :stream_timeout,
    "transport_error" => :transport_error,
    "transport_exit" => :transport_exit,
    "user_cancelled" => :user_cancelled,
    "unknown" => :unknown
  }

  @impl true
  def message(%__MODULE__{message: message}), do: message

  @spec new(keyword()) :: t()
  def new(opts) when is_list(opts) do
    %__MODULE__{
      kind: normalize_kind(Keyword.fetch!(opts, :kind)),
      message: Keyword.get(opts, :message, ""),
      cause: Keyword.get(opts, :cause),
      details: Keyword.get(opts, :details),
      context: normalize_context(Keyword.get(opts, :context)),
      exit_code: Keyword.get(opts, :exit_code)
    }
  end

  @spec from_runtime_failure(ErrorRuntimeFailure.t(), keyword()) :: t()
  def from_runtime_failure(%ErrorRuntimeFailure{} = failure, opts \\ []) do
    new(
      kind: runtime_failure_kind(failure.kind),
      message: Keyword.get(opts, :message, failure.message),
      cause: Keyword.get(opts, :cause, failure.cause || failure),
      details: Keyword.get(opts, :details, failure.stderr),
      context: Map.merge(failure.context || %{}, normalize_context(Keyword.get(opts, :context))),
      exit_code: Keyword.get(opts, :exit_code, failure.exit_code)
    )
  end

  @spec normalize(term(), keyword()) :: t()
  def normalize(%__MODULE__{} = error, opts) do
    new(
      kind: Keyword.get(opts, :kind, error.kind),
      message: Keyword.get(opts, :message, error.message),
      cause: Keyword.get(opts, :cause, error.cause || error),
      details: Keyword.get(opts, :details, error.details),
      context:
        Map.merge(
          normalize_context(error.context),
          normalize_context(Keyword.get(opts, :context))
        ),
      exit_code: Keyword.get(opts, :exit_code, error.exit_code)
    )
  end

  def normalize(%ErrorRuntimeFailure{} = failure, opts), do: from_runtime_failure(failure, opts)

  def normalize(reason, opts) do
    if CoreTransportError.match?(reason) do
      new(
        kind: Keyword.get(opts, :kind, :transport_error),
        message: inspect(CoreTransportError.reason(reason)),
        cause: Keyword.get(opts, :cause, reason),
        context:
          Map.merge(
            CoreTransportError.context(reason),
            normalize_context(Keyword.get(opts, :context))
          )
      )
    else
      new(
        kind: Keyword.get(opts, :kind, :execution_failed),
        message:
          Keyword.get(opts, :message, Exception.message(Exception.normalize(:error, reason))),
        cause: reason,
        context: normalize_context(Keyword.get(opts, :context))
      )
    end
  end

  defp normalize_kind(kind) when is_atom(kind), do: kind

  defp normalize_kind(kind) when is_binary(kind) do
    key =
      kind
      |> String.trim()
      |> String.downcase()
      |> String.replace("-", "_")

    Map.get(@kind_aliases, key, :unknown)
  end

  defp normalize_kind(_kind), do: :unknown

  defp runtime_failure_kind(:auth_error), do: :auth_error
  defp runtime_failure_kind(:cli_not_found), do: :cli_not_found
  defp runtime_failure_kind(:cwd_not_found), do: :config_invalid
  defp runtime_failure_kind(:process_exit), do: :transport_exit
  defp runtime_failure_kind(:transport_error), do: :transport_error
  defp runtime_failure_kind(_kind), do: :execution_failed

  defp normalize_context(nil), do: %{}
  defp normalize_context(context) when is_map(context), do: context
  defp normalize_context(context) when is_list(context), do: Map.new(context)
  defp normalize_context(context), do: %{value: context}
end
