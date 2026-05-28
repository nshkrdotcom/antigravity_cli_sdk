import Config

if cli_path = System.get_env("ANTIGRAVITY_CLI_PATH") do
  config :antigravity_cli_sdk, :cli_path, cli_path
end

if model = System.get_env("ANTIGRAVITY_MODEL") do
  config :antigravity_cli_sdk, :model, model
end

if log_file = System.get_env("ANTIGRAVITY_LOG_FILE") do
  config :antigravity_cli_sdk, :log_file, log_file
end
