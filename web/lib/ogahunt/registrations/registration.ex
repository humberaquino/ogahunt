defmodule Ogahunt.Registrations.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.User

  @mail_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

  schema "registrations" do
    field(:name, :string)
    field(:email, :string)
    field(:encrypted_password, :string)

    # Token used to validate resitration
    field(:token, :string)
    field(:completed, :boolean, default: false)
    # nil if never completed
    field(:completed_at, :naive_datetime_usec)

    # Team link after the user validates the registration
    belongs_to(:team, Team)
    # User who created the registration.
    # Exists only after this registration is validated
    belongs_to(:created_by, User)

    timestamps(updated_at: false)

    # Virtual password fields
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
  end

  def create_changeset(%Registration{} = registration, attrs \\ %{}) do
    registration
    |> cast(attrs, [:name, :email, :password, :password_confirmation, :token])
    |> validate_required([:email, :name, :token])
    |> validate_confirmation(:password, message: "Does not match password!")
    |> validate_length(:name, min: 3, max: 255)
    |> validate_format(:email, @mail_regex)
    |> User.encrypt_password()
    |> validate_required([:encrypted_password])
    |> unique_constraint(:email)
  end
end
