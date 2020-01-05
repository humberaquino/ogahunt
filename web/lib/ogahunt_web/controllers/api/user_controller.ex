defmodule OgahuntWeb.Api.UserController do
  use OgahuntWeb, :controller

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.Role
  alias Ogahunt.Registrations.Registrations
  alias Ogahunt.RegistrationEmail

  action_fallback(OgahuntWeb.Api.ErrorController)

  def show(conn, %{"id" => id}) do
    user = conn.assigns[:user]

    if Integer.to_string(user.id) == id do
      handle_show_user(conn, user)
    else
      handle_not_authorized(conn)
    end
  end

  defp handle_not_authorized(conn) do
    conn
    |> put_status(401)
    |> render("not_authorized.json", error: "Not authorized")
  end

  defp handle_show_user(conn, user) do
    conn
    |> render("user.json", user: user)
  end

  def add_user_to_team(conn, %{"team_id" => team_id, "user" => user_attrs}) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
    user_attrs = Map.merge(user_attrs, %{"user_status_id" => active_status.id})

    user_role = Accounts.get_role_by_name(Role.role_value_user())

    with {:ok, team_user, _user} <- Accounts.add_new_user_to_team(user_attrs, team_id, user_role) do
      render(conn, "add_user_to_team_success.json", team_user: team_user, user_role: user_role)
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render("add_user_to_team_failure.json", changeset: changeset)
    end
  end

  def team_users_list(conn, %{"team_id" => team_id}) do
    team_users = Accounts.get_team_users(team_id)

    render(conn, "team_users_list.json", team_users: team_users)
  end

  def user_teams(conn, %{"id" => user_id}) do
    active_teams = Accounts.get_user_active_teams(user_id)

    render(conn, "user_active_teams.json", teams: active_teams)
  end

  def invite_user_to_team(conn, %{"team_id" => team_id, "email" => email} = params) do
    inviter_user = conn.assigns[:user]
    inviter_name = inviter_user.name

    # Obs: Can only invite if user is owner or admin of team_id
    invite_attrs = Map.merge(params, %{"inviter_id" => inviter_user.id})

    with true <- Accounts.user_can_invite_to(team_id, inviter_user.id),
         {:ok, invite} <- Registrations.invite_team_member(invite_attrs) do
      RegistrationEmail.send_invitation_token_email(
        inviter_name,
        team_id,
        email,
        invite.invite_token
      )

      json(conn, %{success: true})
    else
      false ->
        conn
        |> put_status(401)
        |> json(%{success: false, message: "Operation denied"})

      {:error, :already_invited} ->
        json(conn, %{success: false, error: "User already invited"})
    end
  end
end
