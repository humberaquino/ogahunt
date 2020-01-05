defmodule OgahuntWeb.PageController do
  use OgahuntWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout("simple.html")
    |> render("index.html")
  end
end
