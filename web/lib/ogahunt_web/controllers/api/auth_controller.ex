defmodule OgahuntWeb.Api.AuthController do
  use OgahuntWeb, :controller

  require Logger

  alias Ogahunt.Accounts
  alias Ogahunt.Auth

  action_fallback(OgahuntWeb.Api.ErrorController)

  @rate_limit_signin_secs 30_000
  @rate_limit_signin_count 3

  plug(
    OgahuntWeb.Plug.RateLimit,
    %{
      prefix: "signin",
      limit_secs: @rate_limit_signin_secs,
      limit_count: @rate_limit_signin_count
    }
    when action in [:signin]
  )

  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, login_user} <- Auth.auth_user(email, password) do
      handle_valid_signin(conn, login_user)
    else
      {:error, _error} ->
        conn
        |> render("auth_failure.json", error: "Invalid credentials")
    end
  end

  def handle_valid_signin(conn, user) do
    teams = Accounts.get_user_active_teams(user.id)
    render(conn, "auth_success.json", user: user, teams: teams)
  end
end
