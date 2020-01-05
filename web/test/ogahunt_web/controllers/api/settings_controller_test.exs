defmodule OgahuntWeb.Api.SettingsControllerTest do
  use OgahuntWeb.ConnCase

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts.User

  @user_params %{
    "name" => "John",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  def fixture(:conn) do
    active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
    attrs = Map.merge(@user_params, %{"user_status_id" => active_status.id})

    {:ok, user} = Accounts.create_user(attrs)
    token = User.build_token_from_user(user)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Basic #{token}")

    {conn, user, token}
  end

  defp create_conn(_) do
    {conn, user, token} = fixture(:conn)
    {:ok, conn: conn, user: user, token: token}
  end

  describe "get settings" do
    setup [:create_conn]

    test "GET /settings returns a map all the global config", %{conn: conn} do
      conn = get(conn, "/api/settings", %{})

      response = json_response(conn, 200)

      assert !is_nil(response)

      assert Enum.count(response["roles"]) == 4
      assert Enum.count(response["user_statuses"]) == 4
      assert Enum.count(response["estate_types"]) == 5
      assert Enum.count(response["estate_statuses"]) == 2
      assert Enum.count(response["currencies"]) == 2
    end
  end
end
