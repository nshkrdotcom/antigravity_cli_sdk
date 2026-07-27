# Testing

The default offline gate is:

```bash
mix ci
mix docs --warnings-as-errors
mix deps.sources
xmllint --noout assets/*.svg
mix hex.build
```

`mix ci` runs formatting, warnings-as-errors compilation, tests, strict Credo,
and Dialyzer. Fake executable tests cover invocation rendering, typed
unsupported intents, tagged delivery, idle/total timeout separation, result
fidelity, early cleanup, and bounded child teardown.

Authenticated provider checks are opt-in:

```bash
mix test.live
```

The 0.2.0 release can be prepared without fabricating live evidence when
`agy` is unavailable. In that case the behavior manifest records the gap and
keeps evidence-dependent features unsupported.
