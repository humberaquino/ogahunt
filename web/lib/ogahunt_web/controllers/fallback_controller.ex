defmodule OgahuntWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use OgahuntWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(OgahuntWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(OgahuntWeb.ErrorView)
    |> render(:"403")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(OgahuntWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, error}) do
    IO.inspect(error)

    conn
    |> put_status(500)
    |> put_view(OgahuntWeb.ErrorView)
    |> render(:"500")
  end
end
