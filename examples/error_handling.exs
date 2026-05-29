alias AntigravityCliSdk.{CLI, Options}

case Options.new(timeout_ms: 0) do
  {:error, error} -> IO.puts("invalid_options=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected invalid options error")
end

case CLI.resolve(cli_command: "/definitely/not/agy") do
  {:error, error} ->
    IO.puts("resolve_error_kind=#{inspect(error.kind)}")
    IO.puts("resolve_error=#{Exception.message(error)}")

  {:ok, command} ->
    Mix.raise("expected CLI resolution failure, got #{inspect(command)}")
end
