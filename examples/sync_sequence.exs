Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("sync_sequence", config)

[
  {"first", "ANTIGRAVITY_SEQUENCE_ONE_OK"},
  {"second", "ANTIGRAVITY_SEQUENCE_TWO_OK"}
]
|> Enum.each(fn {label, token} ->
  Helper.assert_exact_text(
    AntigravityCliSdk.run("Reply with exactly: #{token}", Helper.options(config)),
    token,
    "#{label}_text"
  )
end)
