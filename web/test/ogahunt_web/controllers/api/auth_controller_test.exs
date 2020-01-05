defmodule OgahuntWeb.Api.AuthControllerTest do
  use OgahuntWeb.ConnCase

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.Role

  @create_params %{
    "name" => "John",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  def user_fixture(attrs \\ %{}) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
    attrs = Map.merge(attrs, %{"user_status_id" => active_status.id})

    with create_attrs <- Map.merge(@create_params, attrs),
         {:ok, user} <- Accounts.create_user(create_attrs) do
      user
    else
      error -> error
    end
  end

  test "POST /api/signin successful", %{conn: conn} do
    # Create user
    user = user_fixture()
    # Create a team and associate him to it
    {:ok, team} = Accounts.create_team(%{"name" => "team1"})

    owner_role = Accounts.get_role_by_name(Role.role_value_owner())

    {:ok, _team_user} =
      Accounts.create_team_user_association(%{
        "role_id" => owner_role.id,
        "user_id" => user.id,
        "team_id" => team.id
      })

    # Try to login
    conn = post(conn, "/api/signin", %{"email" => user.email, "password" => user.password})

    assert json_response(conn, 200) == %{
             "success" => true,
             "user" => %{
               "id" => user.id,
               "token" => user.api_key,
               "teams" => [
                 %{
                   "id" => team.id,
                   "name" => team.name,
                   "role_id" => owner_role.id,
                   "role" => owner_role.name
                 }
               ]
             }
           }
  end

  test "POST /api/signin failed", %{conn: conn} do
    # Create user
    user = user_fixture()
    # Try to login
    conn = post(conn, "/api/signin", %{"email" => user.email, "password" => "*wrong password*"})

    assert json_response(conn, 200) == %{
             "success" => false,
             "errors" => "Invalid credentials"
           }
  end
end
