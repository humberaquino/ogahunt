defmodule Ogahunt.Estates.Estate do
  use Ecto.Schema
  import Ecto.Changeset

  # @timestamps_opts [type: :naive_datetime_usec]
  alias __MODULE__
  alias Ogahunt.Estates.EstateStatus
  alias Ogahunt.Estates.EstateType
  alias Ogahunt.Estates.EstatePrice
  alias Ogahunt.Estates.EstateLocation
  alias Ogahunt.Estates.EstateImage
  alias Ogahunt.Estates.EstateEvent
  alias Ogahunt.Estates.EstateContact
  alias Ogahunt.Contacts.Contact
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.Team

  schema "estates" do
    field(:name, :string)
    field(:address, :string)
    field(:details, :string)
    field(:version, :integer)
    field(:is_deleted, :boolean)

    belongs_to(:team, Team)

    # Indicates in which status the estate is in. E.g. open, archived
    belongs_to(:estate_status, EstateStatus)
    # Indicates if the state is a house, land, department
    belongs_to(:estate_type, EstateType)

    # Who is responsible
    belongs_to(:created_by, User)
    belongs_to(:updated_by, User)

    # Assignment
    belongs_to(:assigned_to, User)
    belongs_to(:assigned_by, User)
    field(:assigned_at, :naive_datetime_usec)

    # Price
    belongs_to(:current_price, EstatePrice)
    has_many(:prices, EstatePrice)

    # Location
    belongs_to(:location, EstateLocation)

    # Images
    has_many(:images, EstateImage)

    # Events
    has_many(:events, EstateEvent)

    # Contacts
    belongs_to(:main_contact, Contact)
    many_to_many(:contacts, Contact, join_through: EstateContact)

    timestamps()
  end

  def fresh_changeset do
    %Estate{}
    |> Estate.create_changeset()
  end

  @doc false
  def create_changeset(estate, attrs \\ %{}) do
    # Always start with version 1
    attrs = Map.merge(attrs, %{"version" => 1})

    estate
    |> cast(attrs, [
      :name,
      :address,
      :details,
      :version,
      :team_id,
      :location_id,
      :estate_status_id,
      :estate_type_id,
      :created_by_id,
      :main_contact_id,
      :is_deleted
    ])
    |> validate_required([
      :name,
      :version,
      :team_id,
      :estate_status_id,
      :estate_type_id,
      :created_by_id,
      :is_deleted
    ])
  end

  @doc false
  def update_changeset(estate, attrs) do
    estate
    |> cast(attrs, [
      :name,
      :address,
      :details,
      :version,
      :location_id,
      :estate_status_id,
      :estate_type_id,
      :updated_by_id,
      :main_contact_id,
      :is_deleted
    ])
    |> validate_required([
      :name,
      :version,
      :team_id,
      :estate_status_id,
      :estate_type_id,
      :updated_by_id
    ])
  end
end
