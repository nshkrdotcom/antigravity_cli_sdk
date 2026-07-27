# Options

`AntigravityCliSdk.Options` validates the SDK invocation contract before any
process is launched.

| Field | Type | Default | CLI mapping |
| --- | --- | --- | --- |
| `model` | string or nil | core catalog `default` | Core model payload |
| `cli_command` | string or nil | app config/PATH | Path to `agy` |
| `sandbox` | boolean | `false` | `--sandbox` |
| `dangerously_skip_permissions` | boolean | `false` | `--dangerously-skip-permissions` |
| `conversation` | string or nil | `nil` | `--conversation <id>` |
| `continue` | boolean | `false` | `--continue` |
| `add_dirs` | list of strings | `[]` | repeatable `--add-dir <path>` |
| `print_timeout` | string or nil | `nil` | `--print-timeout <value>` |
| `log_file` | string or nil | app config or `nil` | `--log-file <path>` |
| `cwd` | string or nil | `nil` | subprocess working directory |
| `timeout_ms` | positive integer | `300_000` | idle wait between stream events |
| `run_deadline_ms` | positive integer | `300_000` | non-rearming total run ceiling |
| `transport_headless_timeout_ms` | positive integer | `5_000` | Core orphan-reap window |
| `completion_only` | boolean | `false` | common intent; unsupported |
| `output_schema` | term or nil | `nil` | common intent; unsupported |
| `api_key` | string or nil | `nil` | `ANTIGRAVITY_API_KEY` in child env |
| `env` | map | `%{}` | child env overlay |
| `execution_surface` | struct/map/keyword | local | core execution placement |
| `governed_authority` | struct/map/keyword or nil | `nil` | materialized command/cwd/env authority |

Library code reads application configuration through `Application.get_env/3`.
`config/runtime.exs` is responsible for translating OS environment variables
such as `ANTIGRAVITY_CLI_PATH`, `ANTIGRAVITY_MODEL`, and
`ANTIGRAVITY_LOG_FILE` into application config.

`ArgBuilder` always renders the prompt as `["--print", prompt]` first, then
adds Antigravity-native flags. `--add-dir` is repeatable and is never
comma-delimited.

Unsupported common intents fail with a typed SDK error before CLI resolution.
Antigravity `--sandbox` and permission controls are not treated as proof of a
no-tool completion-only posture.
