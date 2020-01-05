defmodule OgahuntWeb.Api.HealthController do
  use OgahuntWeb, :controller

  require Logger

  def index(conn, _params) do
    render(conn, "index.json")
  end

  def live(conn, _params) do
    draining = FT.K8S.TrafficDrainHandler.draining?()

    case draining do
      true ->
        Logger.info("--> Draining in process")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, "Draining")

      false ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "Serving")
    end
  end

  def ready(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Ok")
  end

  def crash(conn, _params) do
    Logger.info("Let's crash")

    raise "This is a test crash"

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Crash")
  end
end
