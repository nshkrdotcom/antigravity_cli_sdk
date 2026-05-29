Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("simple_run", config)

Helper.assert_exact_text(
  AntigravityCliSdk.run("Reply with exactly: ANTIGRAVITY_SIMPLE_RUN_OK", Helper.options(config)),
  "ANTIGRAVITY_SIMPLE_RUN_OK",
  "run_text"
)
