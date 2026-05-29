alias AntigravityCliSdk.{GovernedLaunch, Options}
alias CliSubprocessCore.GovernedAuthority

authority =
  GovernedAuthority.fetch!(
    authority_ref: "authority://agy/example",
    credential_lease_ref: "lease://agy/example",
    connector_instance_ref: "connector-instance://agy/example",
    connector_binding_ref: "connector-binding://agy/example",
    provider_account_ref: "provider-account://agy/example",
    native_auth_assertion_ref: "native-auth://agy/example",
    target_ref: "target://agy/example",
    operation_policy_ref: "operation-policy://agy/example",
    command: "/authority/bin/agy",
    cwd: "/workspace",
    env: %{"ANTIGRAVITY_API_KEY" => "materialized"},
    clear_env?: true
  )

options = %Options{governed_authority: authority}

{:ok, invocation} = GovernedLaunch.invocation(["--print", "hello"], options)
IO.puts("governed_command=#{invocation.command}")
IO.puts("governed_cwd=#{invocation.cwd}")
IO.puts("governed_clear_env=#{inspect(invocation.clear_env?)}")

case Options.new(governed_authority: authority, cwd: "/caller") do
  {:error, error} -> IO.puts("smuggling_rejected=#{Exception.message(error)}")
  {:ok, _options} -> Mix.raise("expected governed cwd smuggling rejection")
end
