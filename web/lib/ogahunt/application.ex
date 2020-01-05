defmodule Ogahunt.Application do
  @moduledoc """
  Main application module
  """
  use Application

  require Logger

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Ogahunt.Repo, []),
      # Start the endpoint when the application starts
      supervisor(OgahuntWeb.Endpoint, []),
      # Start your own worker by calling: Ogahunt.Worker.start_link(arg1, arg2, arg3)
      # worker(Ogahunt.Worker, [arg1, arg2, arg3]),
      {FT.K8S.TrafficDrainHandler, k8s_drainer_opts()}
    ]

    with :ok <- setup_sentry(),
         :ok <- setup_storage() do
      Logger.info("--> APP_BASE_URL: #{Ogahunt.Application.app_base_url()}")

      # See https://hexdocs.pm/elixir/Supervisor.html
      # for other strategies and supported options
      opts = [strategy: :one_for_one, name: Ogahunt.Supervisor]
      Supervisor.start_link(children, opts)
    else
      {:error, error} ->
        {:shutdown, inspect(error)}
    end
  end

  defp setup_storage do
    case Application.get_env(:ogahunt, :gcs_service_account_file) do
      nil ->
        {:error, "GCS service account file not configured. I.e. :gcs_service_account_file"}

      path ->
        case File.read(path) do
          {:ok, content} ->
            json = content |> Poison.decode!()
            client = GcsSigner.Client.from_keyfile(json)
            Application.put_env(:ogahunt, :gcs_signer, client)
            :ok

          {:error, error} ->
            msg = "Can't read path: #{path}. Cause: #{inspect(error)}"
            Logger.error("Error: #{msg}")
            {:error, msg}
        end
    end
  end

  defp setup_sentry do
    case Application.get_env(:sentry, :dsn) do
      nil ->
        Logger.info("Sentry not configured. Skipping")

      _ ->
        env = Application.get_env(:ogahunt, :environment)
        level = System.get_env("RELEASE_LEVEL") || "development"
        version = System.get_env("RELEASE_VERSION") || "dev-version"

        Logger.info("--> Env: #{env}")
        Logger.info("--> RELEASE_LEVEL: #{level}")
        Logger.info("--> RELEASE_VERSION: #{version}")

        Application.put_env(:sentry, :release, version)
        Application.put_env(:sentry, :environment_name, env)
        Application.put_env(:sentry, :tags, %{env: level})
        Logger.info("Sentry configured")
    end

    :ok
  end

  defp k8s_drainer_opts do
    Application.get_env(:ogahunt, :connection_draining, shutdown_delay_ms: 10_000)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OgahuntWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def app_base_url do
    System.get_env("APP_BASE_URL") || "http://localhost:4000"
  end
end
