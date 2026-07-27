# Provider behavior manifest

Verified on 2026-07-27 for `antigravity_cli_sdk 0.2.0`.

The release environment did not contain an installed/authenticated `agy`
binary. Provider behavior claims are therefore limited to the documented CLI
surface already represented by checked-in offline fixtures and tests. The
optional live suite remains the gate for an operator-authenticated binary.

| Behavior | Source/evidence | Support boundary |
| --- | --- | --- |
| plain-text print output | Core Antigravity profile and `TypesTest` | non-empty lines become byte-faithful assistant deltas |
| sandbox | `ArgBuilderTest` and `CLITest` | renders `--sandbox`; does not claim tools/MCP/prompts are absent |
| permission bypass | `ArgBuilderTest` and `CLITest` | renders `--dangerously-skip-permissions` |
| print timeout | `OptionsTest` and argument tests | renders provider-native `--print-timeout` |
| conversation/continue | argument and example suites | renders `--conversation` and `--continue` |
| extra directories | argument and example suites | repeatable `--add-dir`, never comma-delimited |
| governed launch | `GovernedLaunchTest` | command/cwd/env/credential authority fails closed |
| structured output | Core feature manifest and `CLITest` | unsupported; typed rejection before process start |
| completion-only | Core feature manifest and `CLITest` | unsupported; sandbox/permissions are insufficient evidence |
| live provider run | `test/live/antigravity_live_test.exs` | optional; requires installed/authenticated `agy` |

Reversing either unsupported decision requires captured current CLI
version/help, sanitized real frames, repeatable adversarial tests, and proof
that no caller option or ambient provider setting can widen the claimed
posture.
