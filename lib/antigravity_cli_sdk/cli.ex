defmodule AntigravityCliSdk.CLI do
  @moduledoc "Antigravity CLI command resolution and invocation rendering."

  alias AntigravityCliSdk.{ArgBuilder, Configuration, Error, GovernedLaunch, Options}
  alias AntigravityCliSdk.Runtime.CLI, as: RuntimeCLI
  alias CliSubprocessCore.{Command, CommandSpec, ProviderCLI}

  @spec resolve(keyword()) :: {:ok, CommandSpec.t()} | {:error, Error.t()}
  def resolve(opts \\ []) when is_list(opts) do
    configured_cli_path = Keyword.get(opts, :cli_command) || Configuration.cli_path()

    provider_opts =
      opts
      |> Keyword.take([:cli_command, :execution_surface])
      |> maybe_put_cli_path(configured_cli_path)

    case ProviderCLI.resolve(:antigravity, provider_opts, extra_keys: [:cli_path]) do
      {:ok, spec} -> {:ok, spec}
      {:error, reason} -> {:error, Error.normalize(reason, kind: :cli_not_found)}
    end
  end

  @spec build_invocation(keyword()) :: {:ok, Command.t()} | {:error, term()}
  def build_invocation(opts) when is_list(opts) do
    prompt = Keyword.fetch!(opts, :prompt)
    options = opts |> Keyword.get(:options, %Options{}) |> Options.validate!()
    args = ArgBuilder.build_args(options, prompt)

    with {:ok, authority} <- GovernedLaunch.authority(options) do
      case authority do
        nil -> standalone_invocation(args, options)
        _authority -> GovernedLaunch.invocation(args, options)
      end
    end
  rescue
    error in [ArgumentError, KeyError] -> {:error, error}
  end

  @spec build_session_options(String.t(), Options.t(), keyword()) :: keyword()
  def build_session_options(prompt, %Options{} = options, opts \\ []) do
    [
      provider: :antigravity,
      profile: RuntimeCLI.Profile,
      prompt: prompt,
      options: options,
      metadata: Keyword.get(opts, :metadata, %{}),
      subscriber: Keyword.get(opts, :subscriber),
      session_event_tag: Keyword.get(opts, :session_event_tag, RuntimeCLI.session_event_tag()),
      headless_timeout_ms: options.timeout_ms,
      max_stderr_buffer_bytes: options.max_stderr_buffer_bytes
    ]
    |> Keyword.reject(fn {_key, value} -> is_nil(value) end)
  end

  @spec command_args(CommandSpec.t(), [String.t()]) :: [String.t()]
  def command_args(%CommandSpec{} = command, args) when is_list(args) do
    CommandSpec.command_args(command, args)
  end

  @spec start_session(keyword()) ::
          {:ok, pid(), %{info: map(), projection_state: map(), temp_dir: String.t() | nil}}
          | {:error, term()}
  def start_session(opts), do: RuntimeCLI.start_session(opts)

  @spec subscribe(pid(), pid(), reference()) :: :ok | {:error, term()}
  def subscribe(session, pid, ref), do: RuntimeCLI.subscribe(session, pid, ref)

  @spec send_input(pid(), iodata(), keyword()) :: :ok | {:error, term()}
  def send_input(session, input, opts \\ []), do: RuntimeCLI.send_input(session, input, opts)

  @spec end_input(pid()) :: :ok | {:error, term()}
  def end_input(session), do: RuntimeCLI.end_input(session)

  @spec interrupt(pid()) :: :ok | {:error, term()}
  def interrupt(session), do: RuntimeCLI.interrupt(session)

  @spec close(pid()) :: :ok
  def close(session), do: RuntimeCLI.close(session)

  @spec info(pid()) :: map()
  def info(session), do: RuntimeCLI.info(session)

  @spec capabilities() :: [atom()]
  def capabilities, do: RuntimeCLI.capabilities()

  @spec session_event_tag() :: atom()
  def session_event_tag, do: RuntimeCLI.session_event_tag()

  @spec project_event(CliSubprocessCore.Event.t(), map()) ::
          {[AntigravityCliSdk.Types.stream_event()], map()}
  def project_event(event, state), do: RuntimeCLI.project_event(event, state)

  @spec build_env(Options.t()) :: map()
  def build_env(%Options{api_key: api_key, env: env}) do
    env
    |> normalize_env()
    |> maybe_put_env("ANTIGRAVITY_API_KEY", api_key)
  end

  defp standalone_invocation(args, %Options{} = options) do
    with {:ok, command_spec} <-
           resolve(cli_command: options.cli_command, execution_surface: options.execution_surface) do
      {:ok,
       Command.new(command_spec, args,
         cwd: options.cwd,
         env: build_env(options)
       )}
    end
  end

  defp maybe_put_cli_path(opts, nil), do: opts
  defp maybe_put_cli_path(opts, cli_command), do: Keyword.put(opts, :cli_path, cli_command)

  defp normalize_env(env) when is_map(env) do
    Map.new(env, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_env(_env), do: %{}

  defp maybe_put_env(env, _key, nil), do: env
  defp maybe_put_env(env, _key, ""), do: env
  defp maybe_put_env(env, key, value), do: Map.put(env, key, value)
end
