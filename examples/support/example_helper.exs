defmodule AntigravityCliSdk.Examples.Helper do
  @moduledoc false

  @default_prompt "Reply with exactly: ANTIGRAVITY_SDK_EXAMPLE_OK"
  @ssh_options %{"BatchMode" => "yes", "ConnectTimeout" => 10}

  def parse!(argv \\ System.argv()) do
    argv
    |> parse_args(%{
      cwd: nil,
      cli_command: nil,
      model: nil,
      prompt: @default_prompt,
      danger_full_access?: false,
      ssh_host: nil,
      ssh_user: nil,
      ssh_port: nil,
      ssh_identity_file: nil
    })
    |> validate_ssh!()
  end

  def options(config, attrs \\ []) do
    attrs
    |> Keyword.put_new(:dangerously_skip_permissions, true)
    |> Keyword.put_new(:timeout_ms, 120_000)
    |> put_if(:cwd, config.cwd)
    |> put_if(:cli_command, config.cli_command)
    |> put_if(:model, config.model)
    |> put_if(:execution_surface, execution_surface(config))
    |> AntigravityCliSdk.Options.new!()
  end

  def assert_exact_text({:ok, actual}, expected, label) do
    if actual == expected do
      IO.puts("#{label}=#{inspect(actual)}")
    else
      Mix.raise("#{label} mismatch: expected #{inspect(expected)}, got #{inspect(actual)}")
    end
  end

  def assert_exact_text({:error, error}, _expected, label) do
    Mix.raise("#{label} failed: #{Exception.message(error)}")
  end

  def result_text(events) do
    Enum.find_value(events, fn
      %AntigravityCliSdk.Types.ResultEvent{result: text} when is_binary(text) -> text
      _event -> nil
    end)
  end

  def assert_result_text(events, expected, label) do
    actual = result_text(events)

    if actual == expected do
      IO.puts("#{label}=#{inspect(actual)}")
    else
      Mix.raise("#{label} mismatch: expected #{inspect(expected)}, got #{inspect(actual)}")
    end
  end

  def render_args(config, attrs \\ [], prompt \\ "Inspect options") do
    {:ok, rendered} =
      AntigravityCliSdk.Runtime.CLI.render_for_test(
        prompt: prompt,
        options: options(config, attrs)
      )

    rendered.args
  end

  def assert_arg(args, flag) do
    unless flag in args do
      Mix.raise("expected argv to contain #{inspect(flag)}, got #{inspect(args)}")
    end

    IO.puts("argv_contains=#{inspect(flag)}")
  end

  def assert_arg_pair(args, flag, value) do
    pairs = Enum.chunk_every(args, 2, 1, :discard)

    unless [flag, value] in pairs do
      Mix.raise("expected argv pair #{inspect([flag, value])}, got #{inspect(args)}")
    end

    IO.puts("argv_pair=#{inspect([flag, value])}")
  end

  def tmp_dir!(prefix) do
    path =
      Path.join(
        System.tmp_dir!(),
        "#{prefix}-#{System.unique_integer([:positive])}"
      )

    File.rm_rf!(path)
    File.mkdir_p!(path)
    path
  end

  def print_header(name, config) do
    IO.puts("example=#{name}")
    IO.puts("cwd=#{inspect(config.cwd)}")
    IO.puts("cli_command=#{inspect(config.cli_command)}")
    IO.puts("model=#{inspect(config.model)}")
    IO.puts("dangerously_skip_permissions=true")
  end

  defp parse_args([], config), do: config

  defp parse_args(["--cwd", value | rest], config), do: parse_args(rest, %{config | cwd: value})

  defp parse_args(["--cwd=" <> value | rest], config),
    do: parse_args(rest, %{config | cwd: value})

  defp parse_args(["--cli-command", value | rest], config),
    do: parse_args(rest, %{config | cli_command: value})

  defp parse_args(["--cli-command=" <> value | rest], config),
    do: parse_args(rest, %{config | cli_command: value})

  defp parse_args(["--model", value | rest], config),
    do: parse_args(rest, %{config | model: value})

  defp parse_args(["--model=" <> value | rest], config),
    do: parse_args(rest, %{config | model: value})

  defp parse_args(["--prompt", value | rest], config),
    do: parse_args(rest, %{config | prompt: value})

  defp parse_args(["--prompt=" <> value | rest], config),
    do: parse_args(rest, %{config | prompt: value})

  defp parse_args(["--danger-full-access" | rest], config),
    do: parse_args(rest, %{config | danger_full_access?: true})

  defp parse_args(["--ssh-host", value | rest], config),
    do: parse_args(rest, %{config | ssh_host: value})

  defp parse_args(["--ssh-host=" <> value | rest], config),
    do: parse_args(rest, %{config | ssh_host: value})

  defp parse_args(["--ssh-user", value | rest], config),
    do: parse_args(rest, %{config | ssh_user: value})

  defp parse_args(["--ssh-user=" <> value | rest], config),
    do: parse_args(rest, %{config | ssh_user: value})

  defp parse_args(["--ssh-port", value | rest], config),
    do: parse_args(rest, %{config | ssh_port: parse_port!(value)})

  defp parse_args(["--ssh-port=" <> value | rest], config),
    do: parse_args(rest, %{config | ssh_port: parse_port!(value)})

  defp parse_args(["--ssh-identity-file", value | rest], config),
    do: parse_args(rest, %{config | ssh_identity_file: value})

  defp parse_args(["--ssh-identity-file=" <> value | rest], config),
    do: parse_args(rest, %{config | ssh_identity_file: value})

  defp parse_args([unknown | _rest], _config), do: Mix.raise("unknown example flag: #{unknown}")

  defp validate_ssh!(
         %{ssh_host: nil, ssh_user: nil, ssh_port: nil, ssh_identity_file: nil} = config
       ),
       do: config

  defp validate_ssh!(%{ssh_host: nil}), do: Mix.raise("SSH flags require --ssh-host")
  defp validate_ssh!(config), do: config

  defp execution_surface(%{ssh_host: nil}), do: nil

  defp execution_surface(config) do
    transport_options =
      []
      |> put_if(:destination, config.ssh_host)
      |> put_if(:ssh_user, config.ssh_user)
      |> put_if(:port, config.ssh_port)
      |> put_if(:identity_file, config.ssh_identity_file)
      |> Keyword.put(:ssh_options, @ssh_options)

    [surface_kind: :ssh_exec, transport_options: transport_options]
  end

  defp put_if(opts, _key, nil), do: opts
  defp put_if(opts, _key, ""), do: opts
  defp put_if(opts, key, value), do: Keyword.put(opts, key, value)

  defp parse_port!(value) do
    case Integer.parse(value) do
      {port, ""} when port > 0 -> port
      _other -> Mix.raise("invalid --ssh-port: #{inspect(value)}")
    end
  end
end
