defmodule Ogahunt.Repo.Migrations.CreateTeamSupport do
  use Ecto.Migration

  def change do
    create table(:team_status) do
      add(:name, :string)
    end

    create(unique_index(:team_status, [:name]))

    create table(:roles) do
      add(:name, :string)
    end

    create(unique_index(:roles, [:name]))

    create table(:teams) do
      add(:name, :string)

      add(:team_status_id, references(:team_status))

      timestamps()
    end

    create table(:teams_users) do
      add(:user_id, references(:users))
      add(:team_id, references(:teams))

      add(:role_id, references(:roles))

      timestamps()
    end
  end
end
