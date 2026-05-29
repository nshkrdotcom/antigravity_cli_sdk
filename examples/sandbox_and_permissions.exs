Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("sandbox_and_permissions", config)

args =
  Helper.render_args(
    config,
    [sandbox: true, dangerously_skip_permissions: true],
    "Sandbox render"
  )

Helper.assert_arg(args, "--sandbox")
Helper.assert_arg(args, "--dangerously-skip-permissions")
