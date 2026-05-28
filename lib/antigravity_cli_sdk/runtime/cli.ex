defmodule AntigravityCliSdk.Runtime.CLI do
  @moduledoc """
  Session-oriented runtime for Antigravity CLI streams.
  """

  alias AntigravityCliSdk.{CLI, Configuration, Options, Types}
  alias AntigravityCliSdk.Types.{MessageEvent, ResultEvent}
  alias CliSubprocessCore.Event, as: CoreEvent
  alias CliSubprocessCore.Payload
  alias CliSubprocessCore.ProviderProfiles.Antigravity, as: CoreAntigravity
  alias CliSubprocessCore.Session

  @runtime_metadata %{lane: :antigravity_sdk}
  @default_session_event_tag :antigravity_cli_sdk_runtime_cli
  @capabilities [
    :continuation,
    :directory_mapping,
    :sandbox,
    :streaming
  ]

  defmodule ProjectionState do
    @moduledoc false
    defstruct text: "", result_received?: false

    @type t :: %__MODULE__{text: String.t(), result_received?: boolean()}
  end

  defmodule Profile do
    @moduledoc false

    @behaviour CliSubprocessCore.ProviderProfile

    alias AntigravityCliSdk.CLI
    alias CliSubprocessCore.ProviderProfiles.Antigravity, as: CoreAntigravity

    @impl true
    def id, do: :antigravity

    @impl true
    def capabilities, do: CoreAntigravity.capabilities()

    @impl true
    def build_invocation(opts) when is_list(opts), do: CLI.build_invocation(opts)

    @impl true
    def init_parser_state(opts), do: CoreAntigravity.init_parser_state(opts)

    @impl true
    def decode_stdout(line, state), do: CoreAntigravity.decode_stdout(line, state)

    @impl true
    def decode_stderr(chunk, state), do: CoreAntigravity.decode_stderr(chunk, state)

    @impl true
    def handle_exit(reason, state), do: CoreAntigravity.handle_exit(reason, state)

    @impl true
    def transport_options(opts) when is_list(opts), do: CoreAntigravity.transport_options(opts)
  end

  @type start_option ::
          {:prompt, String.t()}
          | {:options, Options.t()}
          | {:subscriber, {pid(), reference()}}
          | {:metadata, map()}
          | {:session_event_tag, atom()}

  @spec start_session([start_option()]) ::
          {:ok, pid(), %{info: map(), projection_state: map(), temp_dir: nil}}
          | {:error, term()}
  def start_session(opts) when is_list(opts) do
    :ok = ensure_app_started()

    prompt = Keyword.fetch!(opts, :prompt)
    options = opts |> Keyword.get(:options, %Options{}) |> Options.validate!()
    maybe_stagger_start()

    session_opts =
      prompt
      |> CLI.build_session_options(options, opts)
      |> Keyword.merge(Options.execution_surface_options(options))
      |> Keyword.update(:metadata, @runtime_metadata, &Map.merge(@runtime_metadata, &1))

    child_spec = %{
      id: {Session, make_ref()},
      start: {Session, :start_link, [session_opts]},
      restart: :temporary,
      type: :worker
    }

    case DynamicSupervisor.start_child(AntigravityCliSdk.SessionSupervisor, child_spec) do
      {:ok, session} ->
        info = Session.info(session)

        {:ok, session,
         %{
           info: put_session_event_tag(info, session_opts),
           projection_state: new_projection_state(info),
           temp_dir: nil
         }}

      {:error, _reason} = error ->
        error
    end
  rescue
    error in [ArgumentError, KeyError] -> {:error, error}
  catch
    :exit, reason -> {:error, reason}
  end

  @spec subscribe(pid(), pid(), reference()) :: :ok | {:error, term()}
  def subscribe(session, pid, ref) when is_pid(session) and is_pid(pid) and is_reference(ref),
    do: Session.subscribe(session, pid, ref)

  @spec send_input(pid(), iodata(), keyword()) :: :ok | {:error, term()}
  def send_input(session, input, _opts \\ []) when is_pid(session),
    do: Session.send_input(session, input)

  @spec end_input(pid()) :: :ok | {:error, term()}
  def end_input(session) when is_pid(session), do: Session.end_input(session)

  @spec interrupt(pid()) :: :ok | {:error, term()}
  def interrupt(session) when is_pid(session), do: Session.interrupt(session)

  @spec close(pid()) :: :ok
  def close(session) when is_pid(session), do: Session.close(session)

  @spec info(pid()) :: map()
  def info(session) when is_pid(session), do: Session.info(session)

  @spec session_event_tag() :: atom()
  def session_event_tag, do: @default_session_event_tag

  @spec capabilities() :: [atom()]
  def capabilities, do: @capabilities

  @spec new_projection_state(map()) :: map()
  def new_projection_state(_info \\ %{}), do: %ProjectionState{}

  @spec project_event(CoreEvent.t(), map()) :: {[Types.stream_event()], map()}
  def project_event(
        %CoreEvent{kind: :assistant_delta} = event,
        %ProjectionState{} = state
      ) do
    projected = Types.project_core_event(event)
    text = state.text <> assistant_text(projected)
    {projected, %{state | text: text}}
  end

  def project_event(
        %CoreEvent{kind: :result} = event,
        %ProjectionState{result_received?: false} = state
      ) do
    projected =
      Enum.map(Types.project_core_event(event), fn
        %ResultEvent{} = result -> %{result | result: state.text}
        other -> other
      end)

    {projected, %{state | result_received?: true}}
  end

  def project_event(%CoreEvent{kind: :result}, %ProjectionState{} = state), do: {[], state}

  def project_event(%CoreEvent{} = event, %ProjectionState{} = state) do
    {Types.project_core_event(event), state}
  end

  @spec stderr_chunk(CoreEvent.t()) :: String.t() | nil
  def stderr_chunk(%CoreEvent{kind: :stderr, payload: %Payload.Stderr{content: content}}),
    do: content

  def stderr_chunk(_event), do: nil

  @doc false
  @spec render_for_test(keyword()) :: {:ok, map()} | {:error, term()}
  def render_for_test(opts) when is_list(opts) do
    prompt = Keyword.get(opts, :prompt, "Hello")
    options = opts |> Keyword.get(:options, %Options{}) |> Options.validate!()

    with {:ok, invocation} <- CLI.build_invocation(prompt: prompt, options: options) do
      {:ok,
       %{
         provider: :antigravity,
         args: invocation.args,
         cwd: invocation.cwd,
         env: invocation.env,
         clear_env?: invocation.clear_env?,
         provider_native: %{
           sandbox: options.sandbox,
           dangerously_skip_permissions: options.dangerously_skip_permissions,
           conversation: options.conversation,
           continue: options.continue,
           add_dirs: options.add_dirs
         }
       }}
    end
  rescue
    error in [ArgumentError, KeyError] -> {:error, error}
  end

  defp ensure_app_started do
    case Application.ensure_all_started(:antigravity_cli_sdk) do
      {:ok, _apps} -> :ok
      {:error, {:already_started, _app}} -> :ok
      {:error, reason} -> raise "failed to start antigravity_cli_sdk: #{inspect(reason)}"
    end
  end

  defp maybe_stagger_start do
    case Configuration.spawn_stagger_ms() do
      value when is_integer(value) and value > 0 -> Process.sleep(value)
      _other -> :ok
    end
  end

  defp assistant_text(projected) do
    Enum.map_join(projected, "", fn
      %MessageEvent{role: :assistant, content: content} -> content || ""
      _event -> ""
    end)
  end

  defp put_session_event_tag(info, opts) when is_map(info) do
    Map.put(info, :session_event_tag, Keyword.fetch!(opts, :session_event_tag))
  end
end
