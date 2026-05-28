# AntigravityCliSdk

Elixir SDK for the Google Antigravity CLI (`agy`). It provides typed streaming
events, synchronous `run/2`, governed launch checks, and the runtime module used
by `agent_session_manager` for the `:antigravity` SDK lane.

## Installation

```elixir
def deps do
  [
    {:antigravity_cli_sdk, "~> 0.1.0", organization: "nshkrdotcom"}
  ]
end
```

Use a path or git dependency until the first Hex publish.

## Quickstart

```elixir
{:ok, text} =
  AntigravityCliSdk.run("Reply with exactly: OK", %AntigravityCliSdk.Options{
    dangerously_skip_permissions: true
  })
```

For streaming:

```elixir
"Explain OTP in one sentence."
|> AntigravityCliSdk.execute(%AntigravityCliSdk.Options{})
|> Enum.each(fn
  %AntigravityCliSdk.Types.MessageEvent{content: text} -> IO.write(text)
  %AntigravityCliSdk.Types.ResultEvent{} -> :ok
  %AntigravityCliSdk.Types.ErrorEvent{} = error -> IO.inspect(error)
end)
```

## Live Example

```bash
mix run examples/simple_stream.exs
```

The example uses the real `agy` binary through `cli_subprocess_core`.

## Documentation

- [Getting Started](guides/getting-started.md)
- [Options](guides/options.md)
- [Streaming](guides/streaming.md)
- [Sessions](guides/sessions.md)
- [Authentication](guides/authentication.md)
- [Architecture](guides/architecture.md)
