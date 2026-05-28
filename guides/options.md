# Options

`AntigravityCliSdk.Options` validates the SDK invocation contract before any
process is launched.

| Field | Type | CLI mapping |
| --- | --- | --- |
| `model` | string or nil | Core model payload; defaults to Antigravity catalog `default` |
| `cli_command` | string or nil | Path to `agy`; otherwise app config/PATH resolution |
| `sandbox` | boolean | `--sandbox` |
| `dangerously_skip_permissions` | boolean | `--dangerously-skip-permissions` |
| `conversation` | string or nil | `--conversation <id>` |
| `continue` | boolean | `--continue` |
| `add_dirs` | list of strings | repeatable `--add-dir <path>` |
| `print_timeout` | string or nil | `--print-timeout <value>` |
| `log_file` | string or nil | `--log-file <path>` |
| `cwd` | string or nil | subprocess working directory |
| `api_key` | string or nil | `ANTIGRAVITY_API_KEY` in child env |
| `env` | map | child env overlay |
| `governed_authority` | struct/map/keyword or nil | materialized command/cwd/env authority |

Library code reads application configuration through `Application.get_env/3`.
`config/runtime.exs` is responsible for translating OS environment variables
such as `ANTIGRAVITY_CLI_PATH`, `ANTIGRAVITY_MODEL`, and
`ANTIGRAVITY_LOG_FILE` into application config.
