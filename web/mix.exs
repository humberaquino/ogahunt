defmodule Ogahunt.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ogahunt,
      version: String.trim(File.read!("VERSION")),
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Ogahunt.Application, []},
      extra_applications: [:sentry, :logger, :runtime_tools, :bamboo, :timex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:ecto_sql, "~> 3.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:cortex, "~> 0.1", only: [:dev]},
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:eliver, "~> 2.0.0"},
      {:jason, "~> 1.1"},
      {:k8s_traffic_plug, github: "Financial-Times/k8s_traffic_plug"},
      {:sentry, "~> 7.0"},
      {:comeonin, "~> 4.0.3"},
      {:bcrypt_elixir, "~> 1.0.4"},
      {:hammer, "~> 5.0"},
      {:excoveralls, "~> 0.9", only: :test},
      {:gcs_signer, "~> 0.2.0"},
      {:poison, "~> 3.1"},
      {:bamboo, "~> 1.1"},
      {:timex, "~> 3.1"},
      {:bodyguard, "~> 2.2"},
      {:observer_cli, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
