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

## Runtime Shape

`start_session/1` accepts a prompt, validated options, metadata, and an optional
tagged subscriber:

```elixir
ref = make_ref()

{:ok, session, info} =
  AntigravityCliSdk.Runtime.CLI.start_session(
    prompt: "Reply with exactly: OK",
    options: %AntigravityCliSdk.Options{},
    subscriber: {self(), ref}
  )
```

The subscriber must be `{pid, reference}`. Untagged subscribers are rejected at
the SDK boundary so new callers do not couple to raw lower-level mailbox
delivery.

`info` includes the core session metadata plus the SDK session event tag used
by ASM and stream consumers.

## Continuation

Continuation uses Antigravity-native controls:

```elixir
AntigravityCliSdk.Session.resume_session("conversation-id", %AntigravityCliSdk.Options{}, "Next")
AntigravityCliSdk.Session.continue_latest(%AntigravityCliSdk.Options{}, "Next")
```

Those helpers map to:

- `--conversation <id>` for exact conversation continuation
- `--continue` for latest conversation continuation

ASM maps `continuation: %{strategy: :exact, provider_session_id: id}` to the
conversation field and `continuation: %{strategy: :latest}` to the continue
flag on the SDK lane.

## Lifecycle Commands

`send_input/3` and `end_input/1` are present for the ASM runtime contract. The
current `agy --print` invocation is prompt-driven, so ordinary callers should
prefer `execute/2` or `run/2` unless they are implementing a runtime adapter.

`interrupt/1` and `close/1` delegate to the underlying core session. They are
safe to call during stream cleanup.

## Session Listing

The portable `agy --print` surface does not currently expose a session-list
command, so `list_provider_sessions/1` returns an empty list.
