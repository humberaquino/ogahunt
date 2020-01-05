defmodule Ogahunt.Registrations.Registrations do
  @moduledoc """
  Logic to register teams
  """

  import Ecto.Query
  import Ecto.Changeset

  alias Ogahunt.Repo
  alias Ogahunt.Registrations.Registration
  alias Ogahunt.Utils
  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.Team
  # alias Ogahunt.Auth
  alias Ogahunt.Accounts.Role
  alias Ogahunt.Registrations.Invitation
  alias Ogahunt.Accounts.UserStatus

  @token_length 64
  @invite_token_length 64

  def create_registration(attrs) do
    token = Utils.random_string(@token_length)
    attrs = Map.merge(attrs, %{"token" => token})

    %Registration{}
    |> Registration.create_changeset(attrs)
    |> Repo.insert()
  end

  def validate_registration(%{"email" => email, "token" => token} = _attrs) do
    query =
      from(
        r in Registration,
        where: r.email == ^email and r.token == ^token and r.completed == false,
        order_by: [desc: r.inserted_at]
      )

    Repo.one(query)
  end

  # with user <- ) do
  #   complete_registration(registration, user)
  # end

  # Check if user exists
  # Doesn't exists: Create user, create team (like signup)
  # Exists:         Create a new team and link to the user

  # Update: completed, completed_at, team_id, created_by_id
  # We assume the registration is valid
  def complete_registration(%Registration{} = registration) do
    # Get the registration
    case Accounts.get_user_by_email(registration.email) do
      nil ->
        complete_registration_without_user(registration)

      user ->
        complete_registration_with_user(registration, user)
    end
  end

  defp complete_registration_without_user(%Registration{} = registration) do
    # Doesn't exists: Create user, create team (like signup)
    with {:ok, user, team, _team_user} <- registration_with_new_user(registration) do
      link_registration(registration, user, team)
    end
  end

  defp complete_registration_with_user(%Registration{} = registration, %User{} = user) do
    # Exists: Create a new team and link to the user

    with {:ok, user, team, _team_user} <- registration_with_exiting_user(registration, user) do
      link_registration(registration, user, team)
    end
  end

  def link_registration(%Registration{} = registration, %User{} = user, %Team{} = team) do
    now = NaiveDateTime.utc_now()

    registration
    |> change(%{completed: true, completed_at: now, created_by_id: user.id, team_id: team.id})
    |> Repo.update()
  end

  defp registration_with_new_user(%Registration{} = registration) do
    # user doesn't exists
    owner_role = Accounts.get_role_by_name(Role.role_value_owner())

    with {:ok, user} <- Accounts.create_user_from_registration(registration),
         team_attrs <- Accounts.build_team_attrs_from(user),
         {:ok, team} <- Accounts.create_team(team_attrs),
         {:ok, team_user} <-
           Accounts.create_team_user_association(%{
             "role_id" => owner_role.id,
             "user_id" => user.id,
             "team_id" => team.id
           }) do
      {:ok, user, team, team_user}
    else
      error ->
        error
    end
  end

  defp registration_with_exiting_user(%Registration{} = _registration, %User{} = user) do
    # user doesn't exists
    owner_role = Accounts.get_role_by_name(Role.role_value_owner())

    with team_attrs <- Accounts.build_team_attrs_from(user),
         {:ok, team} <- Accounts.create_team(team_attrs),
         {:ok, team_user} <-
           Accounts.create_team_user_association(%{
             "role_id" => owner_role.id,
             "user_id" => user.id,
             "team_id" => team.id
           }) do
      {:ok, user, team, team_user}
    else
      error ->
        error
    end
  end

  def invite_team_member(%{"email" => email, "team_id" => team_id} = attrs) do
    case Accounts.user_belongs_team(email, team_id) do
      true ->
        {:error, :already_invited}

      _ ->
        token = Utils.random_string(@invite_token_length)
        expires_at = Timex.now() |> Timex.shift(hours: 168) |> Timex.to_naive_datetime()
        attrs = Map.merge(attrs, %{"invite_expires_at" => expires_at, "invite_token" => token})

        # attrs = Map.merge(attrs, %{"invite_token" => token})
        %Invitation{}
        |> Invitation.create_changeset(attrs)
        |> Repo.insert()
    end
  end

  def validate_invitation(team_id, email, token) do
    now = NaiveDateTime.utc_now()

    query =
      from(
        inv in Invitation,
        where:
          inv.email == ^email and inv.invite_token == ^token and inv.team_id == ^team_id and
            inv.invite_accepted == false and inv.invite_expires_at > ^now,
        order_by: [desc: inv.inserted_at]
      )

    Repo.one(query)
  end

  def complete_accept_invitation(%Invitation{} = invitation, user_attrs \\ %{}) do
    user_role = Accounts.get_role_by_name(Role.role_value_user())

    case Accounts.get_user_by_email(invitation.email) do
      nil ->
        complete_accept_invitation_without_user(invitation, user_attrs, user_role.id)

      user ->
        complete_accept_invitation_with_user(invitation, user, user_role.id)
    end
  end

  defp complete_accept_invitation_without_user(%Invitation{} = invitation, user_attrs, role_id) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())

    user_attrs =
      Map.merge(user_attrs, %{"email" => invitation.email, "user_status_id" => active_status.id})

    # Doesn't exists: Create user and link it to the team
    with {:ok, user} <- Accounts.create_user(user_attrs),
         {:ok, _team_user} <-
           Accounts.create_team_user_association(%{
             "role_id" => role_id,
             "user_id" => user.id,
             "team_id" => invitation.team_id
           }),
         invitation <- link_invitation(invitation, user) do
      # {:ok, team_user, user}
      {:ok, invitation}
    else
      error ->
        {:error, error}
    end
  end

  def complete_accept_invitation_with_user(%Invitation{} = invitation, %User{} = user, role_id) do
    # Exists: Create a new team and link to the user

    with {:ok, _team_user} <-
           Accounts.create_team_user_association(%{
             "role_id" => role_id,
             "user_id" => user.id,
             "team_id" => invitation.team_id
           }),
         invitation <- link_invitation(invitation, user) do
      # {:ok, team_user, user}
      {:ok, invitation}
    else
      error ->
        {:error, error}
    end
  end

  defp link_invitation(%Invitation{} = invitation, %User{} = user) do
    now = NaiveDateTime.utc_now()

    invitation
    |> change(%{invite_accepted: true, invite_accepted_at: now, user_id: user.id})
    |> Repo.update()
  end

  # Check if user can register. USer can only register once.
  # Then they can create more teams but using another endpoint but no throw the registration
  def can_register(%{"email" => email} = _params) do
    case Accounts.get_user_by_email(email) do
      nil ->
        {:ok, true}

      _user ->
        {:error, :already_registered}
    end
  end

  def team_user_invitations(team_id) do
    query =
      from(
        inv in Invitation,
        where: inv.team_id == ^team_id
      )

    Repo.all(query)
  end
end
