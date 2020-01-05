defmodule Ogahunt.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:phone1, :string)
      add(:phone2, :string)
      add(:details, :text)

      add(:version, :integer)

      # A contact is always associated with a team directly
      # even though is associated with a estate indirectly
      add(:team_id, references(:teams))

      timestamps()
    end

    alter table(:estates) do
      # Current pricing pointer
      add(:main_contact_id, references(:contacts))
    end

    create table(:estate_contacts) do
      add(:estate_id, references(:estates))
      add(:contact_id, references(:contacts))

      add(:main_contact, :boolean, default: false, null: false)

      timestamps()
    end
  end
end
