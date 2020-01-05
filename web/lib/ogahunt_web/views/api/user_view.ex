defmodule OgahuntWeb.Api.UserView do
  use OgahuntWeb, :view

  def render("not_authorized.json", %{error: error}) do
    %{
      success: false,
      reason: error
    }
  end

  def render("user.json", %{user: user}) do
    %{
      success: true,
      user: %{
        id: user.id,
        name: user.name,
        email: user.email,
        token: user.api_key
      }
    }
  end

  def render("add_user_to_team_success.json", %{team_user: team_user, user_role: user_role}) do
    %{
      success: true,
      team_user: %{
        team_id: team_user.team_id,
        user_id: team_user.user_id,
        role: user_role.name
      }
    }
  end

  def render("add_user_to_team_failure.json", %{changeset: changeset}) do
    translated_error = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)

    %{
      success: false,
      errors: translated_error
    }
  end

  def render("team_users_list.json", %{team_users: team_users}) do
    users =
      Enum.map(team_users, fn user ->
        %{
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      end)

    %{
      users: users
    }
  end

  def render("user_active_teams.json", %{teams: teams}) do
    teams =
      Enum.map(teams, fn team ->
        %{
          id: team.id,
          name: team.name
        }
      end)

    %{
      teams: teams
    }
  end
end
