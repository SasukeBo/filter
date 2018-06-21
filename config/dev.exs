use Mix.Config

config :logger, level: :debug

config :filter, Filter.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "filter_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
