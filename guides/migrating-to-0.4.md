# Migrating to 0.4

Antigravity CLI SDK 0.4 introduces model and reasoning effort forwarding support
for the Antigravity CLI (`agy --model`, `agy --effort`), supporting `gemini-3.8-flash`
and related catalog models provided by `cli_subprocess_core ~> 0.9.3`.

Update the dependency:

```elixir
{:antigravity_cli_sdk, "~> 0.4.1"}
```

## Model Selection and Reasoning Effort

You can now explicitly select models such as `gemini-3.8-flash` via
`%AntigravityCliSdk.Options{model: "gemini-3.8-flash"}` or the `:model`
option in `AntigravityCliSdk.run/2`. The CLI argument builder will forward
`--model gemini-3.8-flash` to `agy`. Omitting the model or passing `"default"`
continues to allow `agy` to select its own native default. Explicitly selecting
`gemini-3.8-flash` adds its catalog default of medium effort.

Reasoning effort can be specified with `effort: "low"` | `"medium"` | `"high"`
(or atoms `:low`, `:medium`, `:high`). When a model defines a default reasoning
effort in the catalog (e.g. `"medium"` for `gemini-3.8-flash`), it is automatically
forwarded via `--effort` unless overridden.
