defmodule Ogahunt.Estates.EstateEvent do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Estates.Estate
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.Team

  schema "estate_events" do
    belongs_to(:team, Team)
    belongs_to(:estate, Estate)
    belongs_to(:by_user, User)

    field(:change, :map)
    field(:change_type, :string)

    timestamps(updated_at: false)
  end

  def changeset(%EstateEvent{} = estate_event, attrs) do
    estate_event
    |> cast(attrs, [:team_id, :estate_id, :by_user_id, :change, :change_type])
    |> validate_required([:team_id, :by_user_id, :change, :change_type])
  end
end
