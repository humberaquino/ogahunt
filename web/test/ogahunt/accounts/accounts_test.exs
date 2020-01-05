defmodule Ogahunt.AccountsTest do
  use Ogahunt.DataCase

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.Role

  @valid_attrs %{
    "name" => "James",
    "email" => "james@test.com",
    "password" => "test123",
    "password_confirmation" => "test123"
  }

  def user_fixture(attrs \\ %{}) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
    attrs = Map.merge(attrs, %{"user_status_id" => active_status.id})

    with create_attrs <- Map.merge(@valid_attrs, attrs),
         {:ok, user} <- Accounts.create_user(create_attrs) do
      user
      |> Map.merge(%{password: nil, password_confirmation: nil})
    else
      error -> error
    end
  end

  describe "users" do
    test "get_user/1 returns a user by id" do
      user = user_fixture()
      from_db = Accounts.get_user(user.id)
      assert user == from_db
    end

    test "get_user/1 returns a user by email" do
      user = user_fixture()
      from_db = Accounts.get_user_by_email(user.email)
      assert user == from_db
    end

    test "get_user/1 returns nil with no matching user email" do
      _user = user_fixture()
      from_db = Accounts.get_user_by_email("non-existing@email.com")
      assert is_nil(from_db)
    end

    test "create_user/1 creates the user and it has state and api_key" do
      user = user_fixture()
      from_db = Accounts.get_user(user.id)

      assert !is_nil(from_db.user_status)
      assert !is_nil(from_db.api_key)
    end

    test "create_user/1 creates the user in the db and returns it" do
      before_list = Accounts.list_users()
      user = user_fixture()
      after_list = Accounts.list_users()

      # Before the user is not in the DB
      assert !Enum.any?(before_list, fn u -> user == u end)
      # After it should
      assert Enum.any?(after_list, fn u -> user == u end)
    end

    test "create_user/1 fails to create a user with the same email" do
      _user1 = user_fixture()
      {:error, user2} = user_fixture()
      assert !user2.valid?
    end

    test "create_user/1 fails to create an empty user" do
      {:error, user} = Accounts.create_user(%{})
      assert !user.valid?
    end

    test "create_user/1 fails to create an user without email" do
      {_email, attrs_without_email} = Map.pop(@valid_attrs, "email")
      {:error, user} = Accounts.create_user(attrs_without_email)
      assert !user.valid?
    end

    test "create_user/1 fails to create the user without a passsword and password_confirmation" do
      {:error, changeset} = user_fixture(%{"password" => nil, "password_confirmation" => nil})
      assert !changeset.valid?
    end

    test "create_user/1 fails to create the user when the password and the passowrd_confirmation don't match" do
      {:error, changeset} =
        user_fixture(%{"password" => "test", "password_confirmation" => "fail"})

      assert !changeset.valid?
    end

    test "create_team/2 creates a team successfully" do
      # Create team
      {result, team} = Accounts.create_team(%{"name" => "team1"})
      assert result == :ok

      # Team was created
      team_from_db = Accounts.get_team(team.id)
      assert !is_nil(team_from_db)
      # Team value is the same as the one extracted
      assert team_from_db == team
    end

    test "create_team/2 fails to create one without a name" do
      {result, _team} = Accounts.create_team(%{})
      assert result == :error
    end

    test "invite_user_to_team/2 adds a new team member" do
      # Setup: and owner, and a team
      owner = user_fixture()
      {:ok, team} = Accounts.create_team(%{"name" => "test's team", "owner_id" => owner.id})

      email = "team_member1@test.com"
      {:ok, invited_user, team_user} = Accounts.invite_user_to_team(email, team.id)

      # User ant relation got created
      assert !is_nil(invited_user)
      assert !is_nil(team_user)

      # User is invite and the ids of the relationship are correct
      assert invited_user.id == team_user.user_id

      invited_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_invited())
      assert invited_user.user_status_id == invited_status.id
      assert team_user.team_id == team.id
    end

    test "get_user_active_teams/1 gets the list of active user's team" do
      owner = user_fixture()

      # active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
      # attrs = Map.merge(attrs, %{"user_status_id" => active_status.id})

      # Create team
      {:ok, team} = Accounts.create_team(%{"name" => "team1", "owner_id" => owner.id})

      owner_role = Accounts.get_role_by_name(Role.role_value_owner())

      team_membership_attrs = %{
        "role_id" => owner_role.id,
        "role" => "owner",
        "user_id" => owner.id,
        "team_id" => team.id
      }

      {:ok, _team_user} = Accounts.create_team_user_association(team_membership_attrs)

      teams = Accounts.get_user_active_teams(owner.id)

      assert Enum.count(teams) == 1

      assert Enum.any?(teams, fn t ->
               t.id == team.id && t.name == team.name && t.role_id == owner_role.id
             end)
    end

    test "add_user_to_team/1 adds a new user to the team" do
      # user = user_fixture()

      # Create team
      {:ok, team} = Accounts.create_team(%{"name" => "team1"})

      user_attrs = %{
        "name" => "James",
        "email" => "james@test.com",
        "password" => "test123",
        "password_confirmation" => "test123"
      }

      active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())

      user_attrs = Map.merge(user_attrs, %{"user_status_id" => active_status.id})

      user_role = Accounts.get_role_by_name(Role.role_value_user())

      {:ok, team_user, _new_user} = Accounts.add_new_user_to_team(user_attrs, team.id, user_role)

      user = Accounts.get_user_by_email(user_attrs["email"])

      # check if the user associated is the same
      assert team_user.user_id == user.id

      # Check if the team associated has him
      teams = Accounts.get_user_active_teams(user.id)

      assert Enum.any?(teams, fn t ->
               t.id == team_user.team_id && t.role_id == user_role.id
             end)
    end

    test "get_inviter_role_ids/0 gets id of roles admin and owner only" do
      admin_role = Accounts.get_role_by_name(Role.role_value_admin())
      owner_role = Accounts.get_role_by_name(Role.role_value_owner())

      inviter_role_ids = [admin_role.id, owner_role.id]

      role_ids = Accounts.get_inviter_role_ids()

      assert Enum.sort(role_ids) == Enum.sort(inviter_role_ids)
    end

    test "user_can_invite/2 can invite" do
      owner = user_fixture()
      {:ok, team} = Accounts.create_team(%{"name" => "test's team", "owner_id" => owner.id})
      {:ok, _team_user} = Accounts.add_team_owner(team.id, owner.id)

      assert Accounts.user_can_invite_to(team.id, owner.id)
    end
  end
end
