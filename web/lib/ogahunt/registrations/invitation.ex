defmodule Ogahunt.Registrations.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.User

  @mail_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/

  schema "invitations" do
    field(:email, :string)

    field(:invite_token, :string)
    field(:invite_expires_at, :naive_datetime_usec)

    field(:invite_accepted, :boolean, default: false)
    # nil if never accepted
    field(:invite_accepted_at, :naive_datetime_usec)

    # Team link after the user validates the registration
    belongs_to(:team, Team)
    # User who invited this person
    belongs_to(:inviter, User)
    belongs_to(:user, User)

    timestamps(updated_at: false)
  end

  def create_changeset(%Invitation{} = invitation, attrs \\ %{}) do
    invitation
    |> cast(attrs, [
      :email,
      :invite_token,
      :invite_expires_at,
      :invite_accepted,
      :team_id,
      :inviter_id
    ])
    |> validate_required([
      :email,
      :invite_token,
      :invite_expires_at,
      :invite_accepted,
      :team_id,
      :inviter_id
    ])
    |> validate_format(:email, @mail_regex)
  end
end
