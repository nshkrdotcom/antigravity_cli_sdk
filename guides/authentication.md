# Authentication

Antigravity supports three launch postures:

| Posture | Credential source |
| --- | --- |
| Ambient local login | Existing `agy` account/config for the OS user |
| Standalone SDK env | `%Options{api_key: "..."}` or `%Options{env: %{...}}` |
| Governed launch | `CliSubprocessCore.GovernedAuthority` materializes command/cwd/env |

The SDK never puts credentials on argv. `%Options{api_key: value}` becomes
`ANTIGRAVITY_API_KEY` in the child process environment.

## Ambient Local Login

Ambient login is the normal developer path: authenticate `agy` once using its
native command, then run the SDK from the same user account. In this posture the
SDK launches the configured binary and does not claim ownership of the provider
account, auth root, config root, or credential lifecycle.

## Standalone SDK Environment

Use `%AntigravityCliSdk.Options{api_key: value}` or an explicit `env` overlay
when a single invocation should receive runtime environment values:

```elixir
%AntigravityCliSdk.Options{
  api_key: "redacted",
  env: %{"ANTIGRAVITY_EXTRA_SETTING" => "value"}
}
```

The `env` map is normalized to string keys and values before launch. Avoid
putting secrets in logs or metadata.

## Governed Launch

When `governed_authority` is present, `AntigravityCliSdk.GovernedLaunch`
rejects caller-owned command, cwd, env, CLI path, auth root, and config root
overrides. The authority owns those values completely.

Governed launch is fail-closed by design. The caller must provide a verified
authority object that can materialize the launch envelope. Local login state,
ambient app config, and arbitrary caller env maps are not promoted into
governed authority.

## Environment Variables

The supported Antigravity-related environment variables are:

- `ANTIGRAVITY_API_KEY`
- `ANTIGRAVITY_CLI_PATH`
- `ANTIGRAVITY_MODEL`
- `ANTIGRAVITY_LOG_FILE`

`config/runtime.exs` translates CLI path, model, and log file values into
application config. Runtime credentials stay per invocation via `%Options{}` or
governed authority materialization.
