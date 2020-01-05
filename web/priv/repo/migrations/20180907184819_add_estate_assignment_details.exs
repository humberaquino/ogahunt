defmodule Ogahunt.Repo.Migrations.AddEstateAssignmentDetails do
  use Ecto.Migration

  def change do
    alter table(:estates) do
      # Current pricing pointer
      add(:assigned_by_id, references(:users))
      add(:assigned_at, :naive_datetime_usec)
    end
  end
end
