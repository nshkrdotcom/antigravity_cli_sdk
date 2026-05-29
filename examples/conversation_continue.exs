Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("conversation_continue", config)

conversation_args =
  Helper.render_args(config, [conversation: "conversation-example"], "Conversation render")

continue_args = Helper.render_args(config, [continue: true], "Continue render")

Helper.assert_arg_pair(conversation_args, "--conversation", "conversation-example")
Helper.assert_arg(continue_args, "--continue")
