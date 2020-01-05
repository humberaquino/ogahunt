defmodule Ogahunt.Repo.Migrations.AddEventsSupport do
  use Ecto.Migration

  def change do
    create table(:estate_events) do
      add(:team_id, references(:teams))
      add(:estate_id, references(:estates))
      add(:by_user_id, references(:users))

      add(:change, :map)
      add(:change_type, :string)

      timestamps(updated_at: false)
    end
  end
end
