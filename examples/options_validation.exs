alias AntigravityCliSdk.Options

options =
  Options.new!(
    dangerously_skip_permissions: true,
    add_dirs: ["/tmp"],
    print_timeout: "30s"
  )

IO.puts("dangerously_skip_permissions=#{inspect(options.dangerously_skip_permissions)}")
IO.puts("add_dirs_count=#{length(options.add_dirs)}")
IO.puts("print_timeout=#{inspect(options.print_timeout)}")

case Options.new(max_stderr_buffer_bytes: 0) do
  {:error, error} -> IO.puts("invalid_stderr_buffer=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected invalid stderr buffer")
end
