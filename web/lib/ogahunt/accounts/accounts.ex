defmodule Ogahunt.Accounts do
  @moduledoc """
  Main accounts module used to interact with user's info
  """

  import Ecto.Query

  alias __MODULE__
  alias Ogahunt.Repo
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.Role
  alias Ogahunt.Accounts.Team
  alias Ogahunt.Accounts.TeamUser
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.TeamStatus
  alias Ogahunt.Utils
  alias Ogahunt.Registrations.Registration

  @api_key_length 64

  def list_users(), do: Repo.all(User)

  def create_user(attrs) do
    key = Utils.random_string(@api_key_length)
    attrs = Map.merge(attrs, %{"api_key" => key})

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user_from_registration(%Registration{} = registration) do
    key = Utils.random_string(@api_key_length)
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())

    attrs = %{
      "email" => registration.email,
      "name" => registration.name,
      "encrypted_password" => registration.encrypted_password,
      "api_key" => key,
      "user_status_id" => active_status.id
    }

    %User{}
    |> User.changeset_for_registration(attrs)
    |> Repo.insert()
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_team_users(team_id) do
    from(
      u in User,
      join: tu in TeamUser,
      join: r in Role,
      where: tu.team_id == ^team_id and tu.user_id == u.id and r.id == tu.role_id,
      select: %{id: u.id, name: u.name, email: u.email, role_id: tu.role_id, role: r.name}
    )
    |> Repo.all()
  end

  def get_all_roles() do
    Repo.all(Role)
  end

  def get_user_default_team(user_id) do
    case get_user_active_teams(user_id) do
      [team | _rest] ->
        team

      _ ->
        nil
    end
  end

  def get_user_active_teams(user_id) do
    active_team_status =
      TeamStatus.team_status_value_active()
      |> get_team_status_by_name()

    roles = get_all_roles()

    from(
      t in Team,
      join: tu in TeamUser,
      on: t.id == tu.team_id,
      where: tu.user_id == ^user_id and t.team_status_id == ^active_team_status.id,
      select: %{id: t.id, name: t.name, role_id: tu.role_id}
    )
    |> Repo.all()
    |> enhance_team_with_role_names(roles)
  end

  def user_belongs_team(email, team_id) do
    res =
      from(
        u in User,
        join: tu in TeamUser,
        where: u.email == ^email and tu.team_id == ^team_id and tu.user_id == u.id
      )
      |> Repo.one()

    res != nil
  end

  defp enhance_team_with_role_names([], _roles) do
    []
  end

  defp enhance_team_with_role_names(teams, roles) do
    teams
    |> Enum.map(fn team ->
      name = extract_role_name(team.role_id, roles)
      Map.put(team, :role, name)
    end)
  end

  defp extract_role_name(role_id, roles) do
    find =
      Enum.find(roles, fn role ->
        role.id == role_id
      end)

    case find do
      nil ->
        "non-existing"

      role ->
        role.name
    end
  end

  def create_team_user_association(team_membership_attrs) do
    %TeamUser{}
    |> TeamUser.changeset(team_membership_attrs)
    |> Repo.insert()
  end

  def build_team_attrs_from(user) do
    %{"name" => Accounts.team_name_from_user(user)}
  end

  def team_name_from_user(user) do
    "#{user.name}'s team"
  end

  def create_team(attrs \\ %{}) do
    active_team_status =
      TeamStatus.team_status_value_active()
      |> get_team_status_by_name()

    attrs = Map.merge(attrs, %{"team_status_id" => active_team_status.id})

    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def add_team_owner(team_id, user_id) do
    owner_role = Accounts.get_role_by_name(Role.role_value_owner())

    team_membership_attrs = %{
      "role_id" => owner_role.id,
      "user_id" => user_id,
      "team_id" => team_id
    }

    create_team_user_association(team_membership_attrs)
  end

  def get_team(id), do: Repo.get(Team, id)

  def invite_user_to_team(email, team_id) do
    # Create an invited user
    key = Utils.random_string(@api_key_length)

    user_role =
      Role.role_value_user()
      |> get_role_by_name()

    user_status =
      UserStatus.user_status_value_invited()
      |> get_user_status_by_name()

    user_attrs = %{"email" => email, "user_status_id" => user_status.id, "api_key" => key}

    user_changeset =
      %User{}
      |> User.changeset_invitation(user_attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.run(:team_user, fn _repo, %{user: user} ->
      # Link it to an existing team
      team_membership_attrs = %{
        "role_id" => user_role.id,
        "user_id" => user.id,
        "team_id" => team_id
      }

      Accounts.create_team_user_association(team_membership_attrs)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, team_user: team_user}} ->
        # Yay, success!
        {:ok, user, team_user}

      {:error, failed_operation, failed_value, changes_so_far} ->
        # One of the others failed!
        {:error, failed_operation, failed_value, changes_so_far}
    end
  end

  def add_new_user_to_team(user_attrs, team_id, %Role{id: role_id} = _role) do
    with {:ok, user} <- Accounts.create_user(user_attrs),
         {:ok, team_user} <-
           Accounts.create_team_user_association(%{
             "role_id" => role_id,
             "user_id" => user.id,
             "team_id" => team_id
           }) do
      {:ok, team_user, user}
    else
      error ->
        error
    end
  end

  def get_user_status_by_name(name) do
    Repo.get_by!(UserStatus, name: name)
  end

  def get_team_status_by_name(name) do
    Repo.get_by!(TeamStatus, name: name)
  end

  def get_role_by_name(name) do
    Repo.get_by!(Role, name: name)
  end

  def get_inviter_role_ids do
    inviter_role_names = [Role.role_value_admin(), Role.role_value_owner()]

    get_all_roles()
    |> Enum.filter(fn role -> role.name in inviter_role_names end)
    |> Enum.map(fn role -> role.id end)
  end

  def user_can_invite_to(team_id, user_id) do
    inviter_roles = get_inviter_role_ids()

    count =
      from(
        tu in TeamUser,
        where: tu.user_id == ^user_id and tu.team_id == ^team_id and tu.role_id in ^inviter_roles,
        select: count(tu.id)
      )
      |> Repo.one()

    count > 0
  end
end
