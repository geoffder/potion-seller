import Config

token = File.read!("config/bot_token.key") |> String.trim("\n")

config :nostrum,
  token: token,
  num_shards: :auto

# suppress :logger output below warning (due to nostrum verbosity)
config :logger,
  level: :warn

# import_config "#{Mix.env()}.exs"
