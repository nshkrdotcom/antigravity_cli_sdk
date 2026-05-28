# Getting Started

`AntigravityCliSdk` runs `agy --print <prompt>` through
`cli_subprocess_core` and projects the normalized core events into SDK structs.

```elixir
{:ok, text} =
  AntigravityCliSdk.run("Reply with exactly: OK", %AntigravityCliSdk.Options{
    dangerously_skip_permissions: true
  })
```

For local development, authenticate the Antigravity CLI once with its normal
login flow, then run the SDK from the same user account. For CI or governed
launches, pass credentials through the SDK options or a governed authority
rather than through command-line arguments.

Run the included live example:

```bash
mix run examples/simple_stream.exs
```
