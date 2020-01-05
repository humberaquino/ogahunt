defmodule Ogahunt.Registrations.RegistrationsTest do
  use Ogahunt.DataCase
  use Timex

  alias Ogahunt.Registrations.Registrations
  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.User
  # alias Ogahunt.Accounts.Team
  alias(Ogahunt.Accounts.UserStatus)
  alias Ogahunt.Repo
  # alias Ogahunt.Registrations.Registration

  @team_create_params %{"name" => "team1"}
  @user_create_params %{
    "name" => "John",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  def fixture(:registration) do
    attrs = %{
      "name" => "Humber's team",
      "email" => "test1@test.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    {:ok, registration} = Registrations.create_registration(attrs)
    registration
  end

  def fixture(:team, attrs \\ %{}) do
    {:ok, team} =
      Map.merge(@team_create_params, attrs)
      |> Accounts.create_team()

    team
  end

  def fixture_user(attrs \\ %{}) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
    attrs = Map.merge(attrs, %{"user_status_id" => active_status.id})

    with create_attrs <- Map.merge(@user_create_params, attrs),
         {:ok, user} <- Accounts.create_user(create_attrs) do
      user
    else
      error -> error
    end
  end

  test "create_registration/1 Creates a registration sucessfully" do
    # Required: cast(attrs, [:name, :email, :password, :password_confirmation])
    attrs = %{
      "name" => "Humber's team",
      "email" => "test@test.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    assert {:ok, registration} = Registrations.create_registration(attrs)
    assert registration.completed == false
    assert registration.completed_at == nil
    assert registration.email == attrs["email"]
    assert registration.team_id == nil
    assert !is_nil(registration.token)
  end

  test "create_registration/1 Failed to create registration without email or name" do
    # Required: cast(attrs, [:name, :email, :password, :password_confirmation])
    attrs = %{
      "name" => "Humber's team",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    assert {:error, _registration} = Registrations.create_registration(attrs)

    attrs = %{
      "email" => "test@test.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    assert {:error, _registration} = Registrations.create_registration(attrs)
  end

  test "create_registration/1 Failed to create non matching passwords" do
    # Required: cast(attrs, [:name, :email, :password, :password_confirmation])
    attrs = %{
      "name" => "Humber's team",
      "email" => "test@test.com",
      "password" => "123456-1111111",
      "password_confirmation" => "123456"
    }

    assert {:error, _registration} = Registrations.create_registration(attrs)
  end

  test "validate_registration/1 successfully checks if a registration is valid" do
    registration = fixture(:registration)

    attrs = %{"email" => registration.email, "token" => registration.token}

    assert found_registration = Registrations.validate_registration(attrs)

    assert found_registration.email == registration.email
    assert found_registration.token == registration.token
    assert !found_registration.completed
  end

  test "complete_registration/1 completes a registration of a new user" do
    attrs = %{
      "name" => "Humber's team",
      "email" => "test@test.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    assert {:ok, registration} = Registrations.create_registration(attrs)
    assert registration.completed == false

    # Check there are not users
    users = Repo.all(User)
    assert Enum.empty?(users)

    # Now let's complete it
    assert {:ok, registration} = Registrations.complete_registration(registration)

    registration =
      registration
      |> Repo.preload([:created_by])

    # Registration should be completed!
    assert registration.completed == true
    assert registration.completed_at != nil
    assert registration.team_id != nil
    assert registration.created_by_id != nil
    assert registration.created_by.email == attrs["email"]
  end

  test "complete_registration/1 completes a registration of an existing user" do
    attrs = %{
      "name" => "Humber's team",
      "email" => "test@test.com",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    # Create a registration and regiser a new user
    assert {:ok, registration} = Registrations.create_registration(attrs)
    assert registration.completed == false
    assert {:ok, registration} = Registrations.complete_registration(registration)
    assert registration.completed == true

    # Do it again and should work but creating another registation
    assert {:ok, registration2} = Registrations.create_registration(attrs)
    assert registration2.completed == false
    assert {:ok, registration2} = Registrations.complete_registration(registration2)
    assert registration2.completed == true

    # Created by the same user
    assert registration.created_by_id == registration2.created_by_id

    # Check user has 2 teams
    user_id = registration.created_by_id
    active_teams = Accounts.get_user_active_teams(user_id)
    assert Enum.count(active_teams) == 2
  end

  test "invite_team_member/1 invites successfully" do
    # Create owner and team
    team = fixture(:team)
    user = fixture_user()
    # Available for onw week

    email = "test@test.com"

    assert {:ok, invitation} =
             Registrations.invite_team_member(%{
               "email" => email,
               "inviter_id" => user.id,
               "team_id" => team.id
             })

    assert invitation != nil
    assert invitation.email == email
    assert invitation.team_id == team.id
    assert invitation.inviter_id == user.id
    assert invitation.invite_expires_at != nil

    # It should be valid

    assert invitation = Registrations.validate_invitation(team.id, email, invitation.invite_token)

    assert invitation.id != nil
  end

  test "accept_team_invitation/1 works with non linked email" do
    # Create invitation
    team = fixture(:team)
    user = fixture_user()
    # Available for onw week
    expires_at = Timex.now() |> Timex.shift(hours: 168) |> Timex.to_naive_datetime()
    email = "test@test.com"

    assert {:ok, invitation} =
             Registrations.invite_team_member(%{
               "invite_expires_at" => expires_at,
               "email" => email,
               "inviter_id" => user.id,
               "team_id" => team.id
             })

    # Validate and Accept invitation

    assert valid_invitation =
             Registrations.validate_invitation(team.id, email, invitation.invite_token)

    user_attrs = %{
      "name" => "New user",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    Registrations.complete_accept_invitation(valid_invitation, user_attrs)
    # check assertions
  end

  test "accept_team_invitation/1 fails with email already linked to team" do
    # Create invitation
    team = fixture(:team)
    user = fixture_user()
    # Available for onw week
    expires_at = Timex.now() |> Timex.shift(hours: 168) |> Timex.to_naive_datetime()
    email = "test@test.com"

    assert {:ok, invitation} =
             Registrations.invite_team_member(%{
               "invite_expires_at" => expires_at,
               "email" => email,
               "inviter_id" => user.id,
               "team_id" => team.id
             })

    # Complete the registration using the invitation
    user_attrs = %{
      "name" => "New user",
      "password" => "123456",
      "password_confirmation" => "123456"
    }

    assert {:ok, _complete} = Registrations.complete_accept_invitation(invitation, user_attrs)

    assert {:error, _res} =
             Registrations.invite_team_member(%{
               "invite_expires_at" => expires_at,
               "email" => email,
               "inviter_id" => user.id,
               "team_id" => team.id
             })
  end

  test "can_register/1 success when email is not existing" do
    params = %{"email" => "unregister@gmail.com"}
    assert {:ok, _} = Registrations.can_register(params)
  end

  test "can_register/1 fails when trying ot register an existing user" do
    user = fixture_user()
    params = %{"email" => user.email}
    assert {:error, :already_registered} = Registrations.can_register(params)
  end
end
