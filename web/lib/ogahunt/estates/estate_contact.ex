defmodule Ogahunt.Estates.EstateContact do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Estates.Estate
  alias Ogahunt.Contacts.Contact

  schema "estate_contacts" do
    belongs_to(:estate, Estate)
    belongs_to(:contact, Contact)

    field(:main_contact, :boolean)

    timestamps()
  end

  def changeset(%EstateContact{} = estate_contact, attrs) do
    estate_contact
    |> cast(attrs, [:estate_id, :contact_id, :main_contact])
    |> validate_required([:estate_id, :contact_id, :main_contact])
  end
end
