# Error handling

Public failures use `AntigravityCliSdk.Error`; streaming failures use
`AntigravityCliSdk.Types.ErrorEvent`.

Unsupported `completion_only` and `output_schema` requests return
`kind: :unsupported_capability`. The error context preserves the provider,
feature, activating option, and support state supplied by
`CliSubprocessCore.ProviderFeatures.Error`.

When `agy` rejects an explicit model, `AntigravityCliSdk.run/2` returns
`kind: :model_rejected` and the requested model in `context.model`. Use
`AntigravityCliSdk.Models.list_available/1` to refresh the active account's
choices before retrying.

Lifecycle failures are distinct:

- `stream_timeout` means no event arrived within `timeout_ms`;
- `run_deadline_exceeded` means the total non-rearming ceiling elapsed;
- transport failures retain normalized Core transport context;
- provider process failures retain stderr tail and truncation state.

No error path includes the API key in argv or formatted diagnostics.
