Code.require_file("support/example_helper.exs", __DIR__)

alias AntigravityCliSdk.Examples.Helper

config = Helper.parse!()
Helper.print_header("model_selection", config)

{:ok, models} = AntigravityCliSdk.Models.list()
{:ok, default_model} = AntigravityCliSdk.Models.default_model()
selected_model = config.model || default_model || "default"

IO.puts("model_count=#{length(models)}")
IO.puts("default_model=#{inspect(default_model)}")
IO.puts("selected_model=#{selected_model}")

:ok = AntigravityCliSdk.Models.validate_model(selected_model)

options = Helper.options(config, model: selected_model)
IO.puts("model_payload_provider=#{inspect(options.model_payload.provider)}")
IO.puts("model_payload_resolved=#{inspect(options.model_payload.resolved_model)}")
