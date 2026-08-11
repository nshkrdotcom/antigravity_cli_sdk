# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-08-11

### Changed

- Updated the runtime boundary to `cli_subprocess_core ~> 0.7.0`, making the
  SDK compatible with the current Agent Session Manager dependency graph.
- Release checks now prove that repository-only `build_support` tooling is
  excluded from the published package.

## [0.2.0] - 2026-07-27

### Added

- Explicit `completion_only`, `output_schema`, `run_deadline_ms`, and
  `transport_headless_timeout_ms` options with typed unsupported-capability
  errors for the two evidence-dependent common intents.
- Non-rearming total run deadline and a dedicated finite Core transport
  orphan-reap timeout, independent of the existing stream idle timeout.
- Provider behavior, error handling, testing, and ASM integration guides.
- Shared dependency-source helper v6 and release-DAG coverage.

### Changed

- Require `cli_subprocess_core ~> 0.4.0`.
- Preserve Core result status, stop reason, output/object, provider session id,
  usage, duration, metadata, raw envelope, and future payload fields.
  Accumulated assistant text is now only a missing-result fallback.

### Fixed

- Stopped passing the rearming stream idle timeout as the transport headless
  timeout.

## [0.1.0] - 2026-07-13

### Added

- Google Antigravity CLI (`agy`) option/schema validation and native argv
  rendering for sandbox, permissions, conversation continuation, repeatable
  directories, timeout, log file, model, cwd, and environment materialization.
- Typed lazy streaming and synchronous prompt APIs backed by the shared
  Antigravity profile and `CliSubprocessCore` session facade.
- Plain-text assistant delta projection, accumulated result events, bounded
  stderr diagnostics, supervised sessions, and tagged-subscriber lifecycle
  controls.
- Governed authority launch support that fails closed on caller command, cwd,
  environment, API key, model environment, execution surface, auth root, and
  config root smuggling.
- Shared-core model catalog helpers, continuation helpers, SDK-direct examples,
  offline tests, an opt-in live gate, and complete HexDocs guides.
- Runtime configuration boundary for materializing CLI path, model, and log
  file values without direct OS environment reads in library modules.

### Changed

- Restricted the Hex archive to consumer-facing source, configuration, guides,
  examples, and public documentation/assets, with a consistent 200px README.
- Prepared the first public Hex release for Elixir `~> 1.19` and
  `cli_subprocess_core ~> 0.2.0`.

### Security

- API keys are placed only in the child environment, never on argv, and
  governed launches reject unmanaged credential and placement overrides.
- Ordinary CI excludes authenticated live checks; `mix test.live` remains the
  explicit opt-in gate.

### Removed

- The retired `gemini_cli_sdk` is not supported or revived. Antigravity is the
  current Google coding-agent SDK; `gemini_ex` remains a distinct model API
  SDK.

[Unreleased]: https://github.com/nshkrdotcom/antigravity_cli_sdk/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/nshkrdotcom/antigravity_cli_sdk/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/nshkrdotcom/antigravity_cli_sdk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/nshkrdotcom/antigravity_cli_sdk/releases/tag/v0.1.0
