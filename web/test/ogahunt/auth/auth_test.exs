defmodule Ogahunt.AuthTest do
  use Ogahunt.DataCase

  alias Ogahunt.Auth
  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus

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
    test "auth_user/2 success" do
      user = user_fixture()

      {:ok, login_user} = Auth.auth_user(user.email, @valid_attrs["password"])

      assert !is_nil(login_user)
      assert login_user.email == user.email
    end

    test "auth_user/2 fails due to incomplete info" do
      user = user_fixture()
      {:error, reason} = Auth.auth_user(user.email, nil)

      assert !is_nil(reason)
      assert reason == "password is not a string"
    end

    test "auth_user/2 fails due to non existing user" do
      _user = user_fixture()
      {:error, reason} = Auth.auth_user("non@existing.com", "124356")

      assert !is_nil(reason)
      assert reason == "invalid user-identifier"
    end

    test "auth_user/2 fails due to wrong password" do
      user = user_fixture()
      {:error, reason} = Auth.auth_user(user.email, "*wrong password*")

      assert !is_nil(reason)
      assert reason == "invalid password"
    end
  end
end
