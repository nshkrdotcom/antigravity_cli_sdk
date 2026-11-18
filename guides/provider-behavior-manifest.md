# Provider behavior manifest

On 2026-11-18, authenticated `agy` 1.5.10 advertised 18 account-specific
slugs. The live selection was Gemini 4 Hydrogen XHigh. The SDK discovery
example preserved the Argon Medium slug, and the live simple run returned
its expected marker. The same account rejected Carbon. The SDK returned a
typed rejection with the requested slug and no automatic fallback.

| Behavior | Source/evidence | Support boundary |
| --- | --- | --- |
| Gemini 3.8 Flash model and effort | Live `agy models`, `agy --help`, exact-OK CLI smoke at low effort; SDK options and argument tests | `--model gemini-3.8-flash --effort low/medium/high`; malformed effort and conflicting selections rejected |
| Account model discovery | Authenticated `agy models`, SDK model selection example, and Core snapshot fixture | Exact IDs and labels in account order |
| Gemini 4 Carbon | [Google Antigravity CLI reference](https://antigravity.google/docs/cli/headless/) and Core argument fixture | Selectable by eligible accounts. Live execution requires an eligible account. |
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
