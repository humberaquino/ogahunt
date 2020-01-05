defmodule OgahuntWeb.Api.AuthView do
  use OgahuntWeb, :view

  def render("create_success.json", %{user: user, team: team, team_user: team_user}) do
    %{
      success: true,
      user: %{
        id: user.id
      },
      team: %{
        id: team.id,
        name: team.name,
        role_id: team_user.role_id
      }
    }
  end

  def render("create_failure.json", %{changeset: changeset}) do
    translated_error = Ecto.Changeset.traverse_errors(changeset, &translate_error/1)

    %{
      success: false,
      errors: translated_error
    }
  end

  def render("auth_success.json", %{user: user, teams: teams}) do
    %{
      success: true,
      user: %{
        id: user.id,
        token: user.api_key,
        teams: teams
      }
    }
  end

  def render("auth_failure.json", %{error: error}) do
    %{
      success: false,
      errors: error
    }
  end
end
