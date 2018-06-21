use Mix.Config

config :logger, level: :warn

config :filter, Filter.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "filter_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
