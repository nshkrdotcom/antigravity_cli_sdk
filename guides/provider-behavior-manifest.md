# Provider behavior manifest

Release 0.4.0 model and effort behavior checked against authenticated `agy`
`models` and `--help` on 2026-09-07. The catalog includes Gemini 3.8 Flash;
omitted model options preserve agy's native default selection.
Both `examples/simple_run.exs` and `examples/simple_stream.exs` returned their
exact expected responses. Other rows retain their offline evidence boundary.

| Behavior | Source/evidence | Support boundary |
| --- | --- | --- |
| Gemini 3.8 Flash model and effort | Live `agy models`, `agy --help`, exact-OK CLI smoke at low effort; SDK options and argument tests | `--model gemini-3.8-flash --effort low/medium/high`; malformed effort and conflicting selections rejected |
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
