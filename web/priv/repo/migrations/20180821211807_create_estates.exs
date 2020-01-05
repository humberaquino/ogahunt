defmodule Ogahunt.Repo.Migrations.CreateEstates do
  use Ecto.Migration

  def change do
    # Generic
    create table(:currencies) do
      add(:name, :string)
      add(:code, :string)

      timestamps()
    end

    create(unique_index(:currencies, [:code]))

    # Status
    create table(:estate_status) do
      add(:name, :string)
    end

    create(unique_index(:estate_status, [:name]))

    # Types
    create table(:estate_types) do
      add(:name, :string)
    end

    create(unique_index(:estate_types, [:name]))

    # Locations
    create table(:estate_locations) do
      add(:latitude, :float)
      add(:longitude, :float)

      timestamps()
    end

    # Estates
    create table(:estates) do
      # The team whom this estate belongs to
      add(:team_id, references(:teams))

      # Basic attributes
      add(:name, :string)
      add(:address, :string)
      add(:details, :text)
      add(:version, :integer)

      # Basic status and classification
      add(:estate_status_id, references(:estate_status))
      add(:estate_type_id, references(:estate_types))

      # Who is responsible
      add(:created_by_id, references(:users))
      add(:updated_by_id, references(:users))

      add(:assigned_to_id, references(:users))

      # Location
      add(:location_id, references(:estate_locations))

      add(:is_deleted, :boolean, default: false)

      timestamps()
    end

    # Images
    create table(:estate_images) do
      add(:image_url, :string)

      add(:is_deleted, :boolean, default: false)

      add(:estate_id, references(:estates))

      timestamps()
    end
  end
end
