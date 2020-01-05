defmodule Ogahunt.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:user_status) do
      add(:name, :string)
    end

    create table(:users) do
      add(:name, :string)
      add(:email, :string)
      add(:encrypted_password, :string)

      add(:user_status_id, references(:user_status))

      timestamps()
    end

    # create index("compositions", :title)
    create(unique_index(:users, [:email]))
  end
end
