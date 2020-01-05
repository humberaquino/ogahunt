defmodule Ogahunt.Repo.Migrations.CreateUserInvitation do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add(:email, :string)

      add(:invite_token, :string)
      add(:invite_expires_at, :naive_datetime_usec)

      add(:invite_accepted, :boolean)
      add(:invite_accepted_at, :naive_datetime_usec)

      add(:team_id, references(:teams))
      add(:inviter_id, references(:users))
      add(:user_id, references(:users))

      timestamps(updated_at: false)
    end
  end
end
