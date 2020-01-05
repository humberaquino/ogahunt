defmodule Ogahunt.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Estates.Estate
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.User
  alias Ogahunt.Estates.EstateContact

  schema "contacts" do
    field(:details, :string)
    field(:first_name, :string)
    field(:last_name, :string)

    field(:phone1, :string)
    field(:phone2, :string)
    field(:version, :integer)

    field(:is_deleted, :boolean, default: false)

    belongs_to(:team, Team)
    belongs_to(:updated_by, User)

    # Contacts
    many_to_many(:estates, Estate, join_through: EstateContact)

    # has_many(:main_contact_estates, Estate)
    timestamps()
  end

  @doc false
  def changeset(%Contact{} = contact, attrs \\ %{}) do
    contact
    |> cast(attrs, [
      :first_name,
      :last_name,
      :phone1,
      :phone2,
      :details,
      :version,
      :team_id,
      :updated_by_id
    ])
    |> validate_required([:team_id, :first_name, :phone1, :version])
  end

  def create_changeset(attrs \\ %{}) do
    attrs = Map.merge(attrs, %{"version" => 1})

    %Contact{}
    |> changeset(attrs)
  end

  @doc false
  def delete_changeset(%Contact{} = contact, attrs) do
    contact
    |> cast(attrs, [:is_deleted, :updated_by_id])
    |> validate_required([:is_deleted, :updated_by_id])
  end
end
