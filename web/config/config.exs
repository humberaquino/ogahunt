# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ogahunt,
  ecto_repos: [Ogahunt.Repo]

# Ref: http://blog.plataformatec.com.br/2018/10/a-sneak-peek-at-ecto-3-0-breaking-changes/
config :ogahunt, Ogahunt.Repo, migration_timestamps: [type: :naive_datetime_usec]

# Configures the endpoint
config :ogahunt, OgahuntWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iDnyT+MQFoUdeE137X5t6SwpNicYlEpq8JBHZkRs8gMoaozl5w37WfWq5qI0hUqU",
  render_errors: [view: OgahuntWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ogahunt.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :phoenix, :json_library, Jason

config :hammer,
  backend:
    {Hammer.Backend.ETS,
     [
       expiry_ms: 60_000 * 60 * 4,
       cleanup_interval_ms: 60_000 * 10,
       pool_size: 2,
       pool_max_overflow: 4
     ]}
