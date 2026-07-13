# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/nshkrdotcom/antigravity_cli_sdk/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/nshkrdotcom/antigravity_cli_sdk/releases/tag/v0.1.0
