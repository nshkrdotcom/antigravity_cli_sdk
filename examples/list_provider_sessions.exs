case AntigravityCliSdk.list_provider_sessions() do
  {:ok, sessions} ->
    IO.puts("provider_sessions=#{length(sessions)}")

  {:error, error} ->
    Mix.raise("list_provider_sessions failed: #{Exception.message(error)}")
end
