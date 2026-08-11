# ASM integration

`agent_session_manager` may select
`AntigravityCliSdk.Runtime.CLI` as its optional `:antigravity` SDK lane. The SDK
is not a mandatory ASM dependency and does not import ASM.

The lane:

- uses Core session and provider-profile facades;
- accepts a tagged subscriber;
- forwards the dedicated transport orphan-reap timeout;
- preserves Core result fields through `ResultEvent`;
- uses the same completion-only and structured-output capability decisions as
  Core.

For an application that selects the optional lane after both releases are
published:

```elixir
[
  {:agent_session_manager, "~> 0.12.0"},
  {:antigravity_cli_sdk, "~> 0.3.0"}
]
```

Publication order is Core 0.7.0, this SDK 0.3.0, then ASM 0.14.0 or newer.
