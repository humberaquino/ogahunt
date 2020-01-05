defmodule OgahuntWeb.Api.UserControllerTest do
  use OgahuntWeb.ConnCase

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.User

  @create_params %{
    "name" => "John",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  @another_user_params %{
    "name" => "John2",
    "email" => "test2@test.com",
    "password" => "test2",
    "password_confirmation" => "test2"
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

  test "POST /api/team/:team_id/users/add adds a new user to an existing team", %{
    conn: conn
  } do
    user = user_fixture()
    token_base64 = User.build_token_from_user(user)

    # Create a team
    {:ok, team} = Accounts.create_team(%{"name" => "team1"})
    {:ok, _} = Accounts.add_team_owner(team.id, user.id)

    # Call the API
    conn =
      conn
      |> put_req_header("authorization", "Basic #{token_base64}")
      |> post("/api/team/#{team.id}/users/add", %{"user" => @another_user_params})

    response = json_response(conn, 200)

    assert !is_nil(response["team_user"])
  end

  test "POST /api/team/:team_id/users/add fails because the API key is not provided", %{
    conn: conn
  } do
    # Create a team
    {:ok, team} = Accounts.create_team(%{"name" => "team1"})

    # Call the API withoutproviding an api key
    conn = post(conn, "/api/team/#{team.id}/users/add", %{"user" => @create_params})

    assert json_response(conn, 401) == %{
             "message" => "Missing API key"
           }
  end

  test "POST /api/team/:team_id/users/invite creates an invitation for the user", %{
    conn: conn
  } do
    # Create a team
    owner = user_fixture()
    token_base64 = User.build_token_from_user(owner)
    {:ok, team} = Accounts.create_team(%{"name" => "test's team", "owner_id" => owner.id})

    {:ok, _team_user} = Accounts.add_team_owner(team.id, owner.id)

    new_email = "newemail@test.com"

    # Call the API
    conn =
      conn
      |> put_req_header("authorization", "Basic #{token_base64}")
      |> post("/api/team/#{team.id}/users/invite", %{"email" => new_email})

    assert json_response(conn, 200)
  end
end
