# Streaming

`execute/2` is the primary live surface for callers that want incremental
output. It returns a lazy `Stream.resource/3` enumerable. Enumeration starts a
supervised `CliSubprocessCore.Session`, subscribes with a tagged `{pid,
reference}` mailbox channel, and projects normalized core events into SDK
structs.

## Event Types

The SDK emits:

- `AntigravityCliSdk.Types.InitEvent`
- `AntigravityCliSdk.Types.MessageEvent`
- `AntigravityCliSdk.Types.ResultEvent`
- `AntigravityCliSdk.Types.ErrorEvent`

`agy --print` emits plain text, not NDJSON. The core Antigravity provider
profile treats each non-empty stdout line as an assistant delta. The SDK uses
that accumulated text only when the terminal Core result has no result text of
its own.

## Basic Use

```elixir
AntigravityCliSdk.execute("Reply with exactly: OK")
|> Enum.to_list()
```

For user-facing output:

```elixir
"Reply with exactly: OK"
|> AntigravityCliSdk.execute(%AntigravityCliSdk.Options{
  dangerously_skip_permissions: true
})
|> Enum.each(fn
  %AntigravityCliSdk.Types.MessageEvent{content: text} -> IO.write(text)
  %AntigravityCliSdk.Types.ResultEvent{result: result} -> IO.puts("\n#{result}")
  %AntigravityCliSdk.Types.ErrorEvent{} = error -> IO.inspect(error)
  _event -> :ok
end)
```

## Lifecycle

1. `execute/2` validates `AntigravityCliSdk.Options`.
2. `ArgBuilder` renders `agy --print <prompt>` and supported provider flags.
3. `Runtime.CLI` starts a core session through the Antigravity provider profile.
4. `Stream` receives tagged core events and projects them into SDK event
   structs.
5. The stream closes the session when enumeration ends or when a result/error
   event arrives.

Idle timeout and total deadline are independent. Continuous provider output
may rearm the idle wait, but it cannot extend `run_deadline_ms`. The transport
also receives a separate finite `transport_headless_timeout_ms` so a killed
session cannot leave the native child behind indefinitely.

`ResultEvent` preserves the Core terminal status, stop reason, output, object,
provider session id, usage, duration, metadata, raw envelope, and future
payload fields.

The SDK does not expose untagged subscriber delivery. Internal stream
subscriptions always use `{self(), ref}` so mailbox extraction is bounded to
the current stream resource.

## Errors

Launch failures return error events or `{:error, reason}` depending on which
API you call:

- `execute/2` projects runtime failures into `ErrorEvent` values when the
  session starts and then fails.
- `run/2` consumes the stream and returns `{:ok, text}` or `{:error, reason}`.
- direct `Runtime.CLI.start_session/1` returns `{:error, reason}` for invalid
  options, unavailable CLI binaries, or rejected governed launch state.
