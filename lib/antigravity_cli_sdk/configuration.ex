defmodule AntigravityCliSdk.Configuration do
  @moduledoc """
  Runtime defaults for Antigravity CLI SDK execution.

  These values are read from application configuration so callers can configure
  them per environment without direct OS environment reads in library code.
  """

  @defaults [
    command_timeout_ms: 60_000,
    stream_timeout_ms: 300_000,
    default_timeout_ms: 300_000,
    transport_close_grace_ms: 2_000,
    transport_kill_grace_ms: 250,
    max_stderr_buffer_size: 262_144,
    max_inflight_headless: 4,
    spawn_stagger_ms: 75
  ]

  for {key, default} <- @defaults do
    @doc "Returns configured `#{key}`; defaults to `#{default}`."
    @spec unquote(key)() :: pos_integer()
    def unquote(key)(),
      do: Application.get_env(:antigravity_cli_sdk, unquote(key), unquote(default))
  end

  @doc "Returns the configured default Antigravity CLI path, if any."
  @spec cli_path() :: String.t() | nil
  def cli_path, do: Application.get_env(:antigravity_cli_sdk, :cli_path)

  @doc "Returns the configured default Antigravity model, if any."
  @spec model() :: String.t() | nil
  def model, do: Application.get_env(:antigravity_cli_sdk, :model)

  @doc "Returns the configured default Antigravity log file, if any."
  @spec log_file() :: String.t() | nil
  def log_file, do: Application.get_env(:antigravity_cli_sdk, :log_file)

  @doc "Returns all numeric SDK configuration keys and current values."
  @spec all() :: keyword(pos_integer())
  def all do
    Enum.map(@defaults, fn {key, _default} -> {key, apply(__MODULE__, key, [])} end)
  end
end
