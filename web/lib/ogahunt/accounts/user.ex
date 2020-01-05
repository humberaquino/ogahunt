defmodule Ogahunt.Accounts.User do
  @moduledoc """
  Main user module
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.TeamUser
  alias Ogahunt.Accounts.UserStatus

  @mail_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

  schema "users" do
    field(:name, :string)
    field(:email, :string)

    field(:encrypted_password, :string)
    field(:api_key)

    # Virtual password fields
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    belongs_to(:user_status, UserStatus)

    # Teams where the user belongs
    many_to_many(:belong_teams, Team, join_through: TeamUser)

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation, :api_key, :user_status_id])
    |> validate_required([:email, :name, :api_key, :user_status_id])
    |> validate_confirmation(:password, message: "Does not match password!")
    |> validate_length(:name, min: 3, max: 255)
    |> validate_format(:email, @mail_regex)
    |> encrypt_password()
    |> validate_required([:encrypted_password])
    |> unique_constraint(:email)
  end

  def changeset_for_registration(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :encrypted_password, :api_key, :user_status_id])
    |> validate_required([:name, :email, :encrypted_password, :api_key, :user_status_id])
    |> unique_constraint(:email)
  end

  # No need for password yet beacause we invited them
  def changeset_invitation(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :api_key, :user_status_id])
    |> validate_required([:email, :api_key, :user_status_id])
    |> validate_format(:email, @mail_regex)
    |> encrypt_password()
    |> unique_constraint(:email)
  end

  def encrypt_password(changeset) do
    with password when not is_nil(password) <- get_change(changeset, :password) do
      put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
    else
      _ -> changeset
    end
  end

  def build_token_from_user(%User{} = user) do
    payload = "#{user.email}:#{user.api_key}"
    Base.encode64(payload)
  end
end
