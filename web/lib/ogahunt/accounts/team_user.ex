defmodule Ogahunt.Accounts.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.Role
  alias Ogahunt.Accounts.Team

  schema "teams_users" do
    belongs_to(:user, User)
    belongs_to(:team, Team)

    belongs_to(:role, Role)

    timestamps()
  end

  def changeset(%TeamUser{} = team_user, attrs) do
    team_user
    |> cast(attrs, [:user_id, :team_id, :role_id])
    |> validate_required([:user_id, :team_id, :role_id])
  end
end
