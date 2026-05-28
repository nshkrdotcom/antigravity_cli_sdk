defmodule AntigravityCliSdk.Config do
  @moduledoc """
  Runtime workspace helpers for isolated Antigravity CLI launches.
  """

  alias AntigravityCliSdk.Options

  @spec build_runtime_workspace(Options.t() | keyword() | map()) ::
          {:ok, String.t(), String.t() | nil} | {:error, term()}
  def build_runtime_workspace(%Options{cwd: cwd}) when is_binary(cwd) and cwd != "" do
    {:ok, cwd, nil}
  end

  def build_runtime_workspace(%Options{}) do
    tmp_dir = Path.join(System.tmp_dir!(), "antigravity_cli_sdk-" <> unique_suffix())

    case File.mkdir_p(tmp_dir) do
      :ok -> {:ok, tmp_dir, tmp_dir}
      {:error, reason} -> {:error, reason}
    end
  end

  def build_runtime_workspace(attrs) when is_list(attrs) or is_map(attrs) do
    with {:ok, options} <- Options.new(attrs) do
      build_runtime_workspace(options)
    end
  end

  @spec cleanup_runtime_workspace(String.t() | nil) :: :ok
  def cleanup_runtime_workspace(nil), do: :ok

  def cleanup_runtime_workspace(path) when is_binary(path) do
    _ = File.rm_rf(path)
    :ok
  end

  defp unique_suffix do
    System.unique_integer([:positive, :monotonic])
    |> Integer.to_string(36)
  end
end
