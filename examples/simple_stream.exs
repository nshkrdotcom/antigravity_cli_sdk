Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("simple_stream", config)

events =
  "Reply with exactly: ANTIGRAVITY_SIMPLE_STREAM_OK"
  |> AntigravityCliSdk.execute(Helper.options(config))
  |> Enum.to_list()

IO.puts("event_count=#{length(events)}")
Helper.assert_result_text(events, "ANTIGRAVITY_SIMPLE_STREAM_OK", "result_text")
