# Authentication

Antigravity supports three launch postures:

| Posture | Credential source |
| --- | --- |
| Ambient local login | Existing `agy` account/config for the OS user |
| Standalone SDK env | `%Options{api_key: "..."}` or `%Options{env: %{...}}` |
| Governed launch | `CliSubprocessCore.GovernedAuthority` materializes command/cwd/env |

The SDK never puts credentials on argv. `%Options{api_key: value}` becomes
`ANTIGRAVITY_API_KEY` in the child process environment.

When `governed_authority` is present, `AntigravityCliSdk.GovernedLaunch`
rejects caller-owned command, cwd, env, CLI path, auth root, and config root
overrides. The authority owns those values completely.
