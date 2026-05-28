defmodule AntigravityCliSdk.Options do
  @moduledoc """
  Options for an Antigravity CLI headless invocation.

  `:cwd` controls the subprocess working directory. `:add_dirs` maps to
  repeatable `--add-dir` flags and should be used for additional workspace
  visibility.
  """

  alias AntigravityCliSdk.{Configuration, GovernedLaunch}
  alias AntigravityCliSdk.Schema.Options, as: OptionsSchema
  alias CliSubprocessCore.{ExecutionSurface, ModelInput}

  @default_timeout_ms Configuration.default_timeout_ms()
  @default_stderr_bytes Configuration.max_stderr_buffer_size()

  @type t :: %__MODULE__{
          execution_surface: ExecutionSurface.t(),
          governed_authority: CliSubprocessCore.GovernedAuthority.t() | keyword() | map() | nil,
          model_payload: CliSubprocessCore.ModelRegistry.selection() | nil,
          model: String.t() | nil,
          api_key: String.t() | nil,
          cli_command: String.t() | nil,
          sandbox: boolean(),
          dangerously_skip_permissions: boolean(),
          conversation: String.t() | nil,
          continue: boolean(),
          add_dirs: [String.t()],
          debug: boolean(),
          cwd: String.t() | nil,
          timeout_ms: pos_integer(),
          max_stderr_buffer_bytes: pos_integer(),
          log_file: String.t() | nil,
          print_timeout: String.t() | nil,
          env: %{optional(String.t()) => String.t()}
        }

  defstruct execution_surface: %ExecutionSurface{},
            governed_authority: nil,
            model_payload: nil,
            model: nil,
            api_key: nil,
            cli_command: nil,
            sandbox: false,
            dangerously_skip_permissions: false,
            conversation: nil,
            continue: false,
            add_dirs: [],
            debug: false,
            cwd: nil,
            timeout_ms: @default_timeout_ms,
            max_stderr_buffer_bytes: @default_stderr_bytes,
            log_file: nil,
            print_timeout: nil,
            env: %{}

  @spec new(keyword() | map() | t()) :: {:ok, t()} | {:error, term()}
  def new(%__MODULE__{} = opts), do: {:ok, validate!(opts)}

  def new(attrs) when is_list(attrs) or is_map(attrs) do
    {:ok, validate!(struct!(__MODULE__, attrs))}
  rescue
    error in [ArgumentError, KeyError] -> {:error, error}
  end

  @spec new!(keyword() | map() | t()) :: t()
  def new!(attrs) do
    case new(attrs) do
      {:ok, opts} -> opts
      {:error, reason} -> raise ArgumentError, "invalid Antigravity options: #{inspect(reason)}"
    end
  end

  @spec validate!(t()) :: t()
  def validate!(%__MODULE__{} = opts) do
    case OptionsSchema.parse(opts) do
      {:ok, parsed} ->
        parsed
        |> GovernedLaunch.validate_options!()
        |> normalize_model_input!()
        |> GovernedLaunch.validate_options!()

      {:error, {:invalid_options, details}} ->
        raise ArgumentError, validation_message(details)
    end
  end

  @doc false
  @spec normalize_execution_surface(term()) :: {:ok, ExecutionSurface.t()} | {:error, term()}
  def normalize_execution_surface(nil), do: {:ok, %ExecutionSurface{}}
  def normalize_execution_surface(%ExecutionSurface{} = surface), do: {:ok, surface}

  def normalize_execution_surface(surface) when is_list(surface),
    do: ExecutionSurface.new(surface)

  def normalize_execution_surface(%{} = surface), do: ExecutionSurface.new(surface)
  def normalize_execution_surface(other), do: {:error, {:invalid_execution_surface, other}}

  @doc false
  @spec execution_surface_options(t() | ExecutionSurface.t() | nil) :: keyword()
  def execution_surface_options(%__MODULE__{execution_surface: surface}),
    do: execution_surface_options(surface)

  def execution_surface_options(%ExecutionSurface{} = surface) do
    surface
    |> ExecutionSurface.surface_metadata()
    |> Keyword.put(:transport_options, surface.transport_options)
  end

  def execution_surface_options(nil), do: []

  defp normalize_model_input!(%__MODULE__{} = opts) do
    case ModelInput.normalize(:antigravity, Map.from_struct(opts)) do
      {:ok, normalized} ->
        %{opts | model_payload: normalized.selection, model: normalized.selection.resolved_model}

      {:error, _reason} ->
        opts
    end
  end

  defp validation_message(%{issues: [%{path: path} | _], message: message})
       when is_list(path) and path != [] do
    "#{Enum.map_join(path, ".", &to_string/1)}: #{message}"
  end

  defp validation_message(%{message: message}), do: message
end
