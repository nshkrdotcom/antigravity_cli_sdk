# `build_support/` is not shipped in the published package, so its absence is
# how this file knows it is running inside a consumer's deps/ rather than in a
# source checkout. Guard on the file, not on a directory shape: a shape test
# breaks when the repo is vendored at a different depth or used as a git dep.
workspace_helper = Path.expand("build_support/dependency_sources.exs", __DIR__)

if File.regular?(workspace_helper) and not Code.ensure_loaded?(DependencySources) do
  Code.require_file(workspace_helper)
end

defmodule AntigravityCliSdk.MixProject do
  use Mix.Project

  @workspace_checkout? File.regular?(Path.expand("build_support/dependency_sources.exs", __DIR__))

  @app :antigravity_cli_sdk
  @version "0.3.0"
  @source_url "https://github.com/nshkrdotcom/antigravity_cli_sdk"
  @homepage_url "https://hex.pm/packages/antigravity_cli_sdk"
  @docs_url "https://hexdocs.pm/antigravity_cli_sdk"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      docs: docs(),
      dialyzer: dialyzer(),
      name: "AntigravityCliSdk",
      source_url: @source_url,
      homepage_url: @homepage_url
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AntigravityCliSdk.Application, []}
    ]
  end

  def cli do
    [
      preferred_envs: [
        ci: :test,
        "test.live": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      workspace_dep(:cli_subprocess_core, "~> 0.7.0"),
      {:jason, "~> 1.4"},
      {:zoi, "~> 0.18"},
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    "Elixir SDK for the Google Antigravity CLI with typed streams, governed launch, and ASM integration."
  end

  # In a source checkout the registry decides the source (path first). In a
  # published package there is no registry, and the requirement stated here is
  # the whole answer.
  defp workspace_dep(app, hex_requirement, opts \\ []) do
    if @workspace_checkout? do
      apply(DependencySources, :dep, [app, __DIR__, opts])
    else
      if opts == [], do: {app, hex_requirement}, else: {app, hex_requirement, opts}
    end
  end

  defp package do
    [
      name: "antigravity_cli_sdk",
      description: description(),
      licenses: ["MIT"],
      links: %{
        "Hex" => @homepage_url,
        "GitHub" => @source_url,
        "HexDocs" => @docs_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "License" => "#{@source_url}/blob/main/LICENSE"
      },
      maintainers: ["nshkrdotcom"],
      files: ~w(lib assets guides config examples mix.exs README.md LICENSE CHANGELOG.md),
      exclude_patterns: [
        "**/_build/**",
        "**/deps/**",
        "**/doc/**",
        "**/*.beam",
        "**/*.plt",
        "**/*.plt.hash",
        "examples/_output/**"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "AntigravityCliSdk",
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @docs_url,
      assets: %{"assets" => "assets"},
      logo: "assets/antigravity_cli_sdk.svg",
      extras: [
        "README.md": [title: "Overview"],
        "guides/getting-started.md": [title: "Getting Started"],
        "guides/options.md": [title: "Options"],
        "guides/streaming.md": [title: "Streaming"],
        "guides/sessions.md": [title: "Sessions"],
        "guides/authentication.md": [title: "Authentication"],
        "guides/error-handling.md": [title: "Error Handling"],
        "guides/testing.md": [title: "Testing"],
        "guides/asm-integration.md": [title: "ASM Integration"],
        "guides/provider-behavior-manifest.md": [title: "Provider Behavior Manifest"],
        "guides/architecture.md": [title: "Architecture"],
        "guides/migrating-to-0.3.md": [title: "Migrating to 0.3"],
        "examples/README.md": [title: "Examples", filename: "examples"],
        "CHANGELOG.md": [title: "Changelog"],
        LICENSE: [title: "License"]
      ],
      groups_for_extras: [
        "Project Overview": ["README.md"],
        Foundations: [
          "guides/getting-started.md",
          "guides/options.md",
          "guides/authentication.md",
          "guides/error-handling.md",
          "guides/migrating-to-0.3.md"
        ],
        Runtime: [
          "guides/streaming.md",
          "guides/sessions.md"
        ],
        Architecture: [
          "guides/architecture.md",
          "guides/asm-integration.md",
          "guides/provider-behavior-manifest.md"
        ],
        Testing: ["guides/testing.md"],
        Examples: ["examples/README.md"],
        Reference: ["CHANGELOG.md", "LICENSE"]
      ],
      groups_for_modules: [
        "Public API": [AntigravityCliSdk],
        Configuration: [
          AntigravityCliSdk.Options,
          AntigravityCliSdk.Configuration,
          AntigravityCliSdk.CLI,
          AntigravityCliSdk.ArgBuilder,
          AntigravityCliSdk.Models
        ],
        Runtime: [
          AntigravityCliSdk.Config,
          AntigravityCliSdk.GovernedLaunch,
          AntigravityCliSdk.Runtime.CLI,
          AntigravityCliSdk.Session,
          AntigravityCliSdk.Stream
        ],
        Types: [
          AntigravityCliSdk.Types,
          AntigravityCliSdk.Types.InitEvent,
          AntigravityCliSdk.Types.MessageEvent,
          AntigravityCliSdk.Types.ResultEvent,
          AntigravityCliSdk.Types.ErrorEvent
        ],
        Errors: [AntigravityCliSdk.Error],
        Internals: [
          AntigravityCliSdk.Schema,
          AntigravityCliSdk.Schema.Options,
          AntigravityCliSdk.Application
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_core_path: "priv/plts/core",
      plt_local_path: "priv/plts"
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test",
        "credo --strict",
        "dialyzer"
      ],
      "examples.all": ["cmd bash examples/run_all.sh"],
      "test.live": ["test --include live"]
    ]
  end
end
