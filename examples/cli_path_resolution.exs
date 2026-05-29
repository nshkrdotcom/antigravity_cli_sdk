Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("cli_path_resolution", config)

case AntigravityCliSdk.CLI.resolve(cli_command: config.cli_command) do
  {:ok, command} ->
    IO.puts("resolved_command=#{command.program}")

  {:error, error} ->
    Mix.raise("CLI resolution failed: #{Exception.message(error)}")
end

args = Helper.render_args(config, [], "CLI path render")
Helper.assert_arg(args, "--print")
