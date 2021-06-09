# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :instagram_clone,
  ecto_repos: [InstagramClone.Repo]

# Configures the endpoint
config :instagram_clone, InstagramCloneWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "uIsmYl3Gj5ObUCtHT511zDC8ROiZ7m4ZCYnzSkLodRtCmQTVgAQxAD/+xC9GGS7X",
  render_errors: [view: InstagramCloneWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: InstagramClone.PubSub,
  live_view: [signing_salt: "t+C5hJQV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
