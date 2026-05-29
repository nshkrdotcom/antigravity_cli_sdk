Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("session_lifecycle", config)

ref = make_ref()

case AntigravityCliSdk.start_session(
       prompt: "Reply with exactly: ANTIGRAVITY_SESSION_OK",
       options: Helper.options(config),
       subscriber: {self(), ref}
     ) do
  {:ok, session, info} ->
    IO.puts("session_pid_alive=#{inspect(Process.alive?(session))}")
    IO.puts("session_event_tag=#{inspect(Map.get(info.info, :session_event_tag))}")
    :ok = AntigravityCliSdk.CLI.close(session)

  {:error, error} ->
    Mix.raise("start_session failed: #{inspect(error)}")
end
