# Getting Started

`AntigravityCliSdk` runs `agy --print <prompt>` through
`cli_subprocess_core` and projects the normalized core events into SDK structs.

## 1. Add The Dependency

For sibling checkout development:

```elixir
{:antigravity_cli_sdk, path: "../antigravity_cli_sdk"}
```

For Hex after publish:

```elixir
{:antigravity_cli_sdk, "~> 0.1.0", organization: "nshkrdotcom"}
```

## 2. Install And Authenticate `agy`

Install the Antigravity CLI agent binary and authenticate it with its native
login flow for the OS user that will run the SDK. Local development normally
uses that ambient CLI login. CI and governed launches should pass credentials
through `%AntigravityCliSdk.Options{}` or a governed authority instead of
through command-line arguments.

Optional app configuration can point at a non-PATH binary:

```elixir
config :antigravity_cli_sdk,
  cli_path: "/home/app/bin/agy"
```

`config/runtime.exs` in this repo translates `ANTIGRAVITY_CLI_PATH`,
`ANTIGRAVITY_MODEL`, and `ANTIGRAVITY_LOG_FILE` into app config.

## 3. Run A Prompt

```elixir
{:ok, text} =
  AntigravityCliSdk.run("Reply with exactly: OK", %AntigravityCliSdk.Options{
    dangerously_skip_permissions: true
  })
```

`run/2` consumes the stream and returns final text. Use it for quick
prompt/response calls and smoke checks.

## 4. Stream Events

```elixir
"Reply with exactly: OK"
|> AntigravityCliSdk.execute(%AntigravityCliSdk.Options{})
|> Enum.each(fn
  %AntigravityCliSdk.Types.MessageEvent{content: text} -> IO.write(text)
  %AntigravityCliSdk.Types.ResultEvent{result: result} -> IO.inspect(result)
  _event -> :ok
end)
```

Run the included live example:

```bash
mix run examples/simple_stream.exs
```

Run the full SDK-owned example suite:

```bash
~/scripts/with_bash_secrets bash examples/run_all.sh
```

The HexDocs Examples page is sourced from
[examples/README.md](../examples/README.md).

## 5. Use With ASM

`agent_session_manager` resolves the SDK runtime as
`AntigravityCliSdk.Runtime.CLI` for the `:antigravity` provider when the SDK
package is loadable locally.

In an ASM host app, add `antigravity_cli_sdk` as an optional dependency and run:

```elixir
{:ok, result} =
  ASM.query(:antigravity, "Reply with exactly: OK",
    lane: :sdk,
    permission_mode: :bypass
  )
```
