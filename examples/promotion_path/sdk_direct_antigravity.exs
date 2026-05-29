Code.require_file("../support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("promotion_path/sdk_direct_antigravity", config)

Helper.assert_exact_text(
  AntigravityCliSdk.run(
    "Reply with exactly: ANTIGRAVITY_SDK_DIRECT_OK",
    Helper.options(config)
  ),
  "ANTIGRAVITY_SDK_DIRECT_OK",
  "sdk_direct_text"
)
