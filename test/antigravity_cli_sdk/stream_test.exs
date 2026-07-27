defmodule AntigravityCliSdk.StreamTest do
  use ExUnit.Case, async: false

  alias AntigravityCliSdk.{Options, Stream}
  alias AntigravityCliSdk.Types.ErrorEvent

  test "a chatty provider cannot rearm the total run deadline" do
    script =
      executable_fixture!("agy-chatty", """
      while true; do
        printf 'still-running\\n'
        sleep 0.02
      done
      """)

    started_at = System.monotonic_time(:millisecond)

    events =
      "deadline"
      |> Stream.execute(%Options{
        cli_command: script,
        timeout_ms: 5_000,
        run_deadline_ms: 150,
        transport_headless_timeout_ms: 100
      })
      |> Enum.to_list()

    elapsed_ms = System.monotonic_time(:millisecond) - started_at

    assert %ErrorEvent{code: "run_deadline_exceeded", severity: "fatal"} = List.last(events)
    assert elapsed_ms < 2_000
  end

  defp executable_fixture!(name, body) do
    path =
      Path.join(
        System.tmp_dir!(),
        name <> "-" <> Integer.to_string(System.unique_integer([:positive]))
      )

    File.write!(path, "#!/bin/sh\nset -eu\n" <> body)
    File.chmod!(path, 0o755)
    on_exit(fn -> File.rm(path) end)
    path
  end
end
