defmodule AntigravityCliSdk.OptionsTest do
  use ExUnit.Case, async: false

  alias AntigravityCliSdk.Options

  setup do
    original_model = Application.get_env(:antigravity_cli_sdk, :model)
    original_log_file = Application.get_env(:antigravity_cli_sdk, :log_file)

    on_exit(fn ->
      restore_env(:model, original_model)
      restore_env(:log_file, original_log_file)
    end)

    :ok
  end

  test "validates and trims supported options" do
    assert {:ok, opts} =
             Options.new(%{
               model: " default ",
               sandbox: true,
               dangerously_skip_permissions: true,
               conversation: " conv ",
               continue: true,
               add_dirs: [" /repo "],
               debug: true,
               cwd: " /tmp ",
               print_timeout: " 45s ",
               log_file: " /tmp/agy.log ",
               env: %{"A" => "B"}
             })

    assert opts.model == "default"
    assert opts.sandbox == true
    assert opts.dangerously_skip_permissions == true
    assert opts.conversation == "conv"
    assert opts.continue == true
    assert opts.add_dirs == ["/repo"]
    assert opts.cwd == "/tmp"
    assert opts.print_timeout == "45s"
    assert opts.log_file == "/tmp/agy.log"
  end

  test "uses application config defaults without System.get_env in library code" do
    Application.put_env(:antigravity_cli_sdk, :model, "default")
    Application.put_env(:antigravity_cli_sdk, :log_file, "/tmp/configured.log")

    assert {:ok, opts} = Options.new(%{})

    assert opts.model == "default"
    assert opts.log_file == "/tmp/configured.log"
  end

  test "invalid values raise through validate!" do
    assert_raise ArgumentError, fn ->
      Options.validate!(%Options{timeout_ms: 0})
    end
  end

  defp restore_env(key, nil), do: Application.delete_env(:antigravity_cli_sdk, key)
  defp restore_env(key, value), do: Application.put_env(:antigravity_cli_sdk, key, value)
end
