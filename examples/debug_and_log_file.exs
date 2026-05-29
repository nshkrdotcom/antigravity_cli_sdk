Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("debug_and_log_file", config)

log_file = Path.join(Helper.tmp_dir!("agy-log-file"), "agy.log")
args = Helper.render_args(config, [debug: true, log_file: log_file], "Log file render")

Helper.assert_arg_pair(args, "--log-file", log_file)

if "--debug" in args do
  Mix.raise("agy --help does not expose --debug; SDK must not invent that argv")
end

IO.puts("debug_flag_rendered=false")
