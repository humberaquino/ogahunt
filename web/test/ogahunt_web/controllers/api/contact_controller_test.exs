defmodule OgahuntWeb.Api.ContactControllerTest do
  use OgahuntWeb.ConnCase

  alias Ogahunt.Contacts
  alias Ogahunt.Accounts
  # alias Ogahunt.Contacts.Contact

  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts.UserStatus

  @create_attrs %{
    "details" => "some details",
    "first_name" => "some first_name",
    "last_name" => "some last_name",
    "phone1" => "some phone1",
    "phone2" => "some phone2",
    "version" => 42
  }

  @user_params %{
    "name" => "John",
    "email" => "test@test.com",
    "password" => "test",
    "password_confirmation" => "test"
  }

  @team_create_params %{"name" => "team1"}

  def fixture(:contact) do
    {:ok, team} = Accounts.create_team(@team_create_params)
    contact_attrs = Map.merge(@create_attrs, %{"team_id" => team.id})
    {:ok, contact} = Contacts.create_contact(contact_attrs)
    contact
  end

  def fixture(:team) do
    {:ok, team} = Accounts.create_team(@team_create_params)
    team
  end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

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

  describe "team_contact_list" do
    setup [:create_conn, :create_team]

    test "lists all contacts", %{conn: conn, team: team, user: user} do
      # User has to be part of the team
      {:ok, _} = Accounts.add_team_owner(team.id, user.id)

      conn = get(conn, Routes.contact_path(conn, :team_contact_list, team.id))
      assert json_response(conn, 200)["contacts"] == []
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
end
