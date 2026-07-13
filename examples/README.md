# Examples

Runnable examples for `antigravity_cli_sdk`. These examples exercise the
Antigravity SDK directly through `agy`; ASM examples stay in
`agent_session_manager/examples`.

Prerequisites:

- Antigravity CLI (`agy`) installed and authenticated
- `mix deps.get`
- secrets wrapper for live local sweeps: `~/scripts/with_bash_secrets`

Run one example:

```bash
mix run examples/simple_run.exs
mix run examples/add_dirs_repeatable.exs -- --cwd /repo
```

Run all examples:

```bash
bash examples/run_all.sh
~/scripts/with_bash_secrets bash examples/run_all.sh
```

Run one example through the runner:

```bash
bash examples/run_all.sh simple_stream
bash examples/run_all.sh promotion_path/sdk_direct_antigravity --cwd /repo
```

Shared flags:

- `--cwd <path>`
- `--cli-command <path>`
- `--model <id>`
- `--prompt <text>`
- `--danger-full-access`
- `--ssh-host <host>`
- `--ssh-user <user>`
- `--ssh-port <port>`
- `--ssh-identity-file <path>`

SSH flags are parsed consistently, but the default runner does not include a
remote-only example. Passing `--ssh-host` routes examples through the shared
`execution_surface` option.

## Inventory

| Example | SDK surface |
| --- | --- |
| `simple_run.exs` | `AntigravityCliSdk.run/2` |
| `simple_stream.exs` | `AntigravityCliSdk.execute/2`, message/result event accumulation |
| `sync_sequence.exs` | multiple sequential `run/2` calls |
| `model_selection.exs` | `AntigravityCliSdk.Models`, model payload normalization |
| `add_dirs_repeatable.exs` | repeatable `--add-dir` rendering |
| `sandbox_and_permissions.exs` | sandbox and permission rendering |
| `conversation_continue.exs` | conversation and continue option rendering |
| `debug_and_log_file.exs` | log file rendering; debug remains non-argv because `agy --help` exposes no `--debug` |
| `plain_text_line_events.exs` | plain-text assistant delta projection |
| `configuration_stagger.exs` | spawn stagger config and repeated live calls |
| `governed_launch_demo.exs` | governed authority invocation and smuggling rejection |
| `error_handling.exs` | validation and CLI-resolution errors |
| `options_validation.exs` | `AntigravityCliSdk.Options` schema success/failure |
| `cli_path_resolution.exs` | `AntigravityCliSdk.CLI.resolve/1` and rendered `--print` |
| `session_lifecycle.exs` | `start_session/1`, tagged subscriber, and close |
| `list_provider_sessions.exs` | portable session-list contract |
| `promotion_path/sdk_direct_antigravity.exs` | SDK-only promotion path, no ASM imports |

No example imports `agent_session_manager`. Antigravity is the supported Google
coding-agent SDK; the retired `gemini_cli_sdk` remains retired, and `gemini_ex`
is a distinct model API SDK. These examples use `agy` only.
