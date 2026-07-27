# Error handling

Public failures use `AntigravityCliSdk.Error`; streaming failures use
`AntigravityCliSdk.Types.ErrorEvent`.

Unsupported `completion_only` and `output_schema` requests return
`kind: :unsupported_capability`. The error context preserves the provider,
feature, activating option, and support state supplied by
`CliSubprocessCore.ProviderFeatures.Error`.

Lifecycle failures are distinct:

- `stream_timeout` means no event arrived within `timeout_ms`;
- `run_deadline_exceeded` means the total non-rearming ceiling elapsed;
- transport failures retain normalized Core transport context;
- provider process failures retain stderr tail and truncation state.

No error path includes the API key in argv or formatted diagnostics.
