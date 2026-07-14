defmodule AntigravityCliSdk.ReleasePreparationTest do
  use ExUnit.Case, async: true

  @repo_root Path.expand("../..", __DIR__)
  @forbidden_deps [
    :agent_session_manager,
    :gemini_cli_sdk,
    :gemini_ex,
    :claude_agent_sdk,
    :codex_sdk,
    :amp_sdk,
    :cursor_cli_sdk,
    :inference
  ]

  test "release metadata targets Antigravity CLI SDK 0.1.0 on Elixir 1.19" do
    project = Mix.Project.config()

    assert project[:version] == "0.1.0"
    assert project[:elixir] == "~> 1.19"
    assert project[:docs][:source_ref] == "v0.1.0"
    assert project[:homepage_url] == "https://hex.pm/packages/antigravity_cli_sdk"
  end

  test "publish mode selects cli_subprocess_core 0.2 from Hex" do
    assert "~> 0.2.0" ==
             @repo_root
             |> DependencySources.deps(publish?: true)
             |> Keyword.fetch!(:cli_subprocess_core)
  end

  test "package metadata is complete for the first public Hex release" do
    package = Mix.Project.config()[:package]

    assert package[:name] == "antigravity_cli_sdk"
    assert package[:licenses] == ["MIT"]
    assert package[:maintainers] == ["nshkrdotcom"]
    assert package[:links]["GitHub"] == "https://github.com/nshkrdotcom/antigravity_cli_sdk"
    assert package[:links]["Hex"] == "https://hex.pm/packages/antigravity_cli_sdk"
    assert package[:links]["HexDocs"] == "https://hexdocs.pm/antigravity_cli_sdk"

    for required <-
          ~w(lib assets build_support guides config examples mix.exs README.md LICENSE CHANGELOG.md) do
      assert required in package[:files]
    end

    refute ".formatter.exs" in package[:files]

    refute File.read!(Path.join(@repo_root, "README.md")) =~ "organization:"
    refute File.read!(Path.join(@repo_root, "guides/getting-started.md")) =~ "organization:"
  end

  test "README and HexDocs use the named 200px release asset" do
    project = Mix.Project.config()
    readme = File.read!(Path.join(@repo_root, "README.md"))
    header = readme |> String.split("\n") |> Enum.take(20) |> Enum.join("\n")

    assert project[:docs][:assets] == %{"assets" => "assets"}
    assert project[:docs][:logo] == "assets/antigravity_cli_sdk.svg"
    assert header =~ ~s(src="assets/antigravity_cli_sdk.svg")
    assert header =~ ~s(width="200")
    assert header =~ ~s(href="https://github.com/nshkrdotcom/antigravity_cli_sdk")
    assert header =~ ~s(href="LICENSE")
    assert length(Regex.scan(~r/img\.shields\.io/, header)) == 2
  end

  test "package docs preserve the Google coding-agent ownership boundary" do
    docs =
      ["README.md", "guides/getting-started.md", "examples/README.md"]
      |> Enum.map_join("\n", &File.read!(Path.join(@repo_root, &1)))

    assert docs =~ "supported Google coding-agent SDK"
    assert docs =~ "retired `gemini_cli_sdk`"
    assert docs =~ "`gemini_ex`"
    assert docs =~ "model API SDK"
  end

  test "ordinary CI excludes authenticated live tests" do
    helper = File.read!(Path.join(@repo_root, "test/test_helper.exs"))
    assert helper =~ "ExUnit.start(exclude: [:live])"
  end

  test "SDK implementation exposes no raw Execution Plane modules" do
    for path <- Path.wildcard(Path.join(@repo_root, "lib/**/*.ex")) do
      refute File.read!(path) =~ "ExecutionPlane.",
             "raw Execution Plane reference in #{Path.relative_to(path, @repo_root)}"
    end
  end

  test "SDK-direct promotion example does not import ASM" do
    source =
      File.read!(Path.join(@repo_root, "examples/promotion_path/sdk_direct_antigravity.exs"))

    refute source =~ "alias ASM"
    refute source =~ "import ASM"
    refute source =~ "require ASM"
    refute source =~ "ASM."
  end

  test "antigravity_cli_sdk does not declare upper or sibling SDK dependencies" do
    declared = Mix.Project.config()[:deps] |> Enum.map(&dep_name/1) |> MapSet.new()

    for dep <- @forbidden_deps do
      refute MapSet.member?(declared, dep),
             "antigravity_cli_sdk must not declare dependency on #{inspect(dep)}"
    end
  end

  defp dep_name({name, _requirement}), do: name
  defp dep_name({name, _requirement, _opts}), do: name
end
