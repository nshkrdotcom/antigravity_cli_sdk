# Migrating to 0.3

Antigravity CLI SDK 0.3 aligns its subprocess runtime with
`cli_subprocess_core ~> 0.7.0`. This makes it compatible with
`agent_session_manager` 0.14 and newer releases on the same core line.

Update the dependency:

```elixir
{:antigravity_cli_sdk, "~> 0.3.0"}
```

No Antigravity-facing API migration is required. Applications that declare
`cli_subprocess_core` directly must allow the `~> 0.7.0` line.
