# Streaming

`execute/2` returns a lazy `Stream.resource/3` enumerable. The stream starts a
supervised `CliSubprocessCore.Session`, subscribes to normalized core events,
and projects them into:

- `AntigravityCliSdk.Types.InitEvent`
- `AntigravityCliSdk.Types.MessageEvent`
- `AntigravityCliSdk.Types.ResultEvent`
- `AntigravityCliSdk.Types.ErrorEvent`

`agy --print` emits plain text. Each non-empty stdout line becomes an assistant
message delta. The SDK accumulates those deltas and attaches the final text to
the result event.

```elixir
AntigravityCliSdk.execute("Reply with exactly: OK")
|> Enum.to_list()
```
