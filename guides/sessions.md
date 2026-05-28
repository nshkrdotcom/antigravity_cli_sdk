# Sessions

The SDK session runtime is `AntigravityCliSdk.Runtime.CLI`. It exposes the
runtime-kit functions expected by `agent_session_manager`:

- `start_session/1`
- `subscribe/3`
- `send_input/3`
- `end_input/1`
- `interrupt/1`
- `close/1`
- `info/1`

Continuation uses Antigravity-native controls:

```elixir
AntigravityCliSdk.Session.resume_session("conversation-id", %AntigravityCliSdk.Options{}, "Next")
AntigravityCliSdk.Session.continue_latest(%AntigravityCliSdk.Options{}, "Next")
```

The portable `agy --print` surface does not currently expose a session-list
command, so `list_provider_sessions/1` returns an empty list.
