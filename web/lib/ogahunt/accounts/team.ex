defmodule Ogahunt.Accounts.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.TeamUser
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.TeamStatus

  schema "teams" do
    field(:name, :string)

    belongs_to(:team_status, TeamStatus)

    # User of the team
    many_to_many(:users, User, join_through: TeamUser)

    timestamps()
  end

  def changeset(%Team{} = team, attrs) do
    team
    |> cast(attrs, [:name, :team_status_id])
    |> validate_required([:name, :team_status_id])
  end
end
