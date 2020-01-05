use Mix.Config

config :ogahunt, :environment, :test

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ogahunt, OgahuntWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ogahunt, Ogahunt.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USERNAME") || "humber",
  password: System.get_env("PG_PASSWORD") || "",
  hostname: System.get_env("PG_HOST") || "localhost",
  database: "ogahunt_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :ogahunt,
  gcs_service_account_file: "secrets/gcs-service-account.json",
  gcs_image_bucket: "ogahunt-images"

config :ogahunt, Ogahunt.Mailer, adapter: Bamboo.TestAdapter
