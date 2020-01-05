defmodule Ogahunt.Repo.Migrations.CreateTeamRegistration do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add(:name, :string)
      add(:email, :string)
      add(:encrypted_password, :string)

      add(:token, :string)
      add(:completed, :boolean)
      add(:completed_at, :naive_datetime_usec)

      add(:team_id, references(:teams))
      add(:created_by_id, references(:users))

      timestamps(updated_at: false)
    end
  end
end
