defmodule Ogahunt.Repo.Migrations.AddContactDeleted do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      # Current pricing pointer
      add(:is_deleted, :boolean, default: false)
      add(:updated_by_id, references(:users))
    end
  end
end
