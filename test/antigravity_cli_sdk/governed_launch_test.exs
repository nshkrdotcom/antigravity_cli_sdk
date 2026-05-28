defmodule AntigravityCliSdk.GovernedLaunchTest do
  use ExUnit.Case, async: true

  alias AntigravityCliSdk.{GovernedLaunch, Options}
  alias CliSubprocessCore.GovernedAuthority

  test "rejects caller-owned launch overrides when governed authority is present" do
    authority = authority()

    assert_raise ArgumentError, ~r/governed Antigravity launch rejected/, fn ->
      Options.validate!(%Options{governed_authority: authority, cwd: "/repo"})
    end
  end

  test "builds governed invocation from authority only" do
    authority = authority()

    assert {:ok, command} =
             GovernedLaunch.invocation(
               ["--print", "hello"],
               %Options{governed_authority: authority}
             )

    assert command.command == "/bin/agy"
    assert command.cwd == "/governed"
    assert command.env == %{"ANTIGRAVITY_API_KEY" => "materialized"}
    assert command.clear_env? == true
  end

  defp authority do
    GovernedAuthority.fetch!(
      authority_ref: "authority",
      credential_lease_ref: "lease",
      connector_instance_ref: "connector-instance",
      connector_binding_ref: "connector-binding",
      provider_account_ref: "provider-account",
      native_auth_assertion_ref: "auth-assertion",
      target_ref: "target",
      operation_policy_ref: "operation-policy",
      command: "/bin/agy",
      cwd: "/governed",
      env: %{"ANTIGRAVITY_API_KEY" => "materialized"},
      clear_env?: true
    )
  end
end
