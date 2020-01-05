defmodule OgahuntWeb.Api.EstateControllerTest do
  use OgahuntWeb.ConnCase

  alias Ogahunt.Estates
  # alias Ogahunt.Estates.Estate
  alias Ogahunt.Estates.EstateType
  alias Ogahunt.Estates.EstateStatus

  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.UserStatus

  @create_attrs %{
    address: "some address",
    details: "some details",
    name: "some name"
    # version: 1
  }

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

  @team_create_params %{"name" => "team1"}
  def fixture(:team) do
    {:ok, team} = Accounts.create_team(@team_create_params)

    team
  end

  def fixture(:estate_status_open) do
    Estates.get_estate_status_by_name(EstateStatus.estate_status_value_open())
  end

  def fixture(:estate_type_house) do
    Estates.get_estate_type_by_name(EstateType.estate_type_value_house())
  end

  describe "create estate" do
    setup [:create_conn, :create_team, :create_estate_status_open, :create_estate_type_house]

    test "/team/:team_id/estate list all estates of the team. Valid key for the team" do
      # 1. Create with an owner and add a estate
      active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())

      attrs =
        Map.merge(@user_params, %{
          "email" => "user1@email.com",
          "user_status_id" => active_status.id
        })

      {:ok, user1} = Accounts.create_user(attrs)
      token_user1 = User.build_token_from_user(user1)

      {:ok, team1} = Accounts.create_team(%{"name" => "team1"})

      # Add owner
      {:ok, _} = Accounts.add_team_owner(team1.id, user1.id)

      # associate
      conn1 =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Basic #{token_user1}")

      conn1 = get(conn1, "/api/team/#{team1.id}/estate", %{})

      # Check the estate is listed. Should work
      response = json_response(conn1, 200)
      assert response == %{"estates" => []}

      # 2. Add another user and build another connection. It should get a forbidden

      active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())

      attrs2 =
        Map.merge(@user_params, %{
          "email" => "user2@email.com",
          "user_status_id" => active_status.id
        })

      {:ok, user2} = Accounts.create_user(attrs2)
      token_user2 = User.build_token_from_user(user2)

      {:ok, team2} = Accounts.create_team(%{"name" => "team2"})

      # Add owner
      {:ok, _} = Accounts.add_team_owner(team2.id, user2.id)

      conn2 =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("authorization", "Basic #{token_user2}")

      # Obs. We use team1 id on purpose! Is not a mistake. This has to fail
      conn2 = get(conn2, "/api/team/#{team1.id}/estate", %{})

      # Check the estate is listed. Should work
      assert response(conn2, 403)
    end

    test "renders estate when data is valid. Complete case", %{
      conn: conn,
      team: team,
      user: user,
      estate_status_open: estate_status_open,
      estate_type_house: estate_type_house
    } do
      attrs =
        Map.merge(@create_attrs, %{
          "team_id" => team.id,
          "status" => estate_status_open.name,
          "type" => estate_type_house.name,
          # "created_by_id" => user.id,
          "current_price" => %{
            "amount" => "100000",
            "currency" => "USD"
          },
          "location" => %{
            "latitude" => "12.3456",
            "longitude" => "7.890"
          },
          "main_contact" => %{
            "first_name" => "Mike",
            "last_name" => "Jordan",
            "phone1" => "123456",
            "phone2" => nil,
            "details" => "Is a test detail"
          }
        })

      {:ok, _} = Accounts.add_team_owner(team.id, user.id)

      conn = post(conn, "/api/team/#{team.id}/estate", %{"estate" => attrs})

      response = json_response(conn, 201)

      estate_response = response["estate"]
      assert %{"id" => _id} = estate_response

      type_name = estate_type_house.name
      status_name = estate_status_open.name

      assert %{"version" => 1, "type" => ^type_name, "status" => ^status_name} = estate_response

      # Check price is the same, has an id and a version
      price_response = estate_response["current_price"]
      assert !is_nil(price_response["id"])
      assert price_response["amount"] == "100000.00"

      # # Check location is the same, has an id and a version
      location_response = estate_response["location"]
      assert !is_nil(location_response["id"])
      assert location_response["latitude"] == 12.3456

      # Check contact is the same, has an id and a version
      contact_response = estate_response["main_contact"]
      assert !is_nil(contact_response["id"])
    end
  end

  defp create_conn(_) do
    {conn, user, token} = fixture(:conn)
    {:ok, conn: conn, user: user, token: token}
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end

  defp create_estate_status_open(_) do
    estate_status_open = fixture(:estate_status_open)
    {:ok, estate_status_open: estate_status_open}
  end

  defp create_estate_type_house(_) do
    estate_type_house = fixture(:estate_type_house)
    {:ok, estate_type_house: estate_type_house}
  end
end
