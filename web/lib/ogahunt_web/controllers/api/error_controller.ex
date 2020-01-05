defmodule OgahuntWeb.Api.ErrorController do
  use Phoenix.Controller

  alias OgahuntWeb.ErrorView

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> render(ErrorView, "400.json", [])
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "404.json", [])
  end

  def call(conn, _) do
    conn
    |> put_status(500)
    |> render(ErrorView, "500.json", [])
  end
end
