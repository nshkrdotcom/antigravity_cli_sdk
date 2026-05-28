prompt =
  case System.argv() do
    [] -> "Reply with exactly: ANTIGRAVITY_SIMPLE_STREAM_OK"
    args -> Enum.join(args, " ")
  end

options = %AntigravityCliSdk.Options{
  dangerously_skip_permissions: true,
  timeout_ms: 120_000
}

prompt
|> AntigravityCliSdk.execute(options)
|> Enum.each(fn
  %AntigravityCliSdk.Types.MessageEvent{role: :assistant, content: content} ->
    IO.write(content)

  %AntigravityCliSdk.Types.ResultEvent{result: result} ->
    IO.puts("")
    IO.puts("result=#{inspect(result)}")

  %AntigravityCliSdk.Types.ErrorEvent{} = error ->
    IO.puts("error=#{inspect(error)}")

  _event ->
    :ok
end)
