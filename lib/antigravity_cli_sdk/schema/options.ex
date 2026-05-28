defmodule AntigravityCliSdk.Schema.Options do
  @moduledoc false

  alias AntigravityCliSdk.{Configuration, Options, Schema}
  alias CliSubprocessCore.{ExecutionSurface, Schema.Conventions}

  @spec schema() :: Zoi.schema()
  def schema do
    Zoi.map(
      %{
        execution_surface: execution_surface_schema(),
        governed_authority: Conventions.optional_any(),
        model_payload: Conventions.optional_any(),
        model: Conventions.optional_trimmed_string(),
        api_key: Conventions.optional_trimmed_string(),
        cli_command: Conventions.optional_trimmed_string(),
        sandbox: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        dangerously_skip_permissions:
          Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        conversation: Conventions.optional_trimmed_string(),
        continue: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        add_dirs: Conventions.string_list([]),
        debug: Zoi.default(Zoi.optional(Zoi.nullish(Zoi.boolean())), false),
        cwd: Conventions.optional_trimmed_string(),
        timeout_ms: positive_integer_schema(:timeout_ms, Configuration.default_timeout_ms()),
        max_stderr_buffer_bytes:
          positive_integer_schema(
            :max_stderr_buffer_bytes,
            Configuration.max_stderr_buffer_size()
          ),
        log_file: Conventions.optional_trimmed_string(),
        print_timeout: Conventions.optional_trimmed_string(),
        env: Conventions.default_map(%{})
      },
      unrecognized_keys: :error
    )
  end

  @spec parse(Options.t() | map()) ::
          {:ok, Options.t()}
          | {:error, {:invalid_options, CliSubprocessCore.Schema.error_detail()}}
  def parse(%Options{} = opts), do: parse(Map.from_struct(opts))

  def parse(attrs) when is_map(attrs) do
    case Schema.parse(schema(), attrs, :invalid_options) do
      {:ok, parsed} -> {:ok, project(parsed)}
      {:error, {:invalid_options, details}} -> {:error, {:invalid_options, details}}
    end
  end

  @doc false
  def normalize_positive_integer(value, opts), do: normalize_positive_integer(value, :value, opts)

  @doc false
  def normalize_positive_integer(value, field, _opts) do
    if is_integer(value) and value > 0 do
      {:ok, value}
    else
      {:error, "#{field} must be positive, got #{inspect(value)}"}
    end
  end

  @doc false
  def normalize_execution_surface(value, opts), do: normalize_execution_surface(value, [], opts)

  @doc false
  def normalize_execution_surface(value, _args, _opts) do
    case Options.normalize_execution_surface(value) do
      {:ok, surface} ->
        {:ok, surface}

      {:error, {:invalid_execution_surface, other}} ->
        {:error, "invalid execution_surface: #{inspect(other)}"}

      {:error, reason} ->
        {:error, "invalid execution_surface: #{inspect(reason)}"}
    end
  end

  defp execution_surface_schema do
    Zoi.default(
      Zoi.optional(
        Zoi.nullish(Zoi.any() |> Zoi.transform({__MODULE__, :normalize_execution_surface, []}))
      ),
      %ExecutionSurface{}
    )
  end

  defp positive_integer_schema(field, default) do
    Zoi.default(
      Zoi.optional(
        Zoi.nullish(
          Zoi.any()
          |> Zoi.transform({__MODULE__, :normalize_positive_integer, [field]})
        )
      ),
      default
    )
  end

  defp project(parsed) do
    %Options{
      execution_surface: Map.get(parsed, :execution_surface, %ExecutionSurface{}),
      governed_authority: Map.get(parsed, :governed_authority),
      model_payload: Map.get(parsed, :model_payload),
      model: configured_model(blank_to_nil(Map.get(parsed, :model))),
      api_key: blank_to_nil(Map.get(parsed, :api_key)),
      cli_command: blank_to_nil(Map.get(parsed, :cli_command)),
      sandbox: Map.get(parsed, :sandbox, false),
      dangerously_skip_permissions: Map.get(parsed, :dangerously_skip_permissions, false),
      conversation: blank_to_nil(Map.get(parsed, :conversation)),
      continue: Map.get(parsed, :continue, false),
      add_dirs: Map.get(parsed, :add_dirs, []),
      debug: Map.get(parsed, :debug, false),
      cwd: blank_to_nil(Map.get(parsed, :cwd)),
      timeout_ms: Map.get(parsed, :timeout_ms, Configuration.default_timeout_ms()),
      max_stderr_buffer_bytes:
        Map.get(parsed, :max_stderr_buffer_bytes, Configuration.max_stderr_buffer_size()),
      log_file: configured_log_file(blank_to_nil(Map.get(parsed, :log_file))),
      print_timeout: blank_to_nil(Map.get(parsed, :print_timeout)),
      env: Map.get(parsed, :env, %{})
    }
  end

  defp configured_model(nil), do: Configuration.model()
  defp configured_model(value), do: value

  defp configured_log_file(nil), do: Configuration.log_file()
  defp configured_log_file(value), do: value

  defp blank_to_nil(value) when value in [nil, ""], do: nil
  defp blank_to_nil(value), do: value
end
