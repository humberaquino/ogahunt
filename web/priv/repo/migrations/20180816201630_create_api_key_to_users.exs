defmodule Ogahunt.Repo.Migrations.CreateApiKeyToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:api_key, :string)
    end
  end
end
