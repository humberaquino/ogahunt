defmodule Ogahunt.ContactsTest do
  use Ogahunt.DataCase

  alias Ogahunt.Contacts
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts
  # alias Ogahunt.Estates
  # alias Ogahunt.Estates.EstateStatus
  # alias Ogahunt.Estates.EstateType

  describe "contacts" do
    alias Ogahunt.Contacts.Contact

    @valid_attrs %{
      "details" => "some details",
      "first_name" => "some first_name",
      "last_name" => "some last_name",
      "phone1" => "some phone1",
      "phone2" => "some phone2"
    }
    @update_attrs %{
      "details" => "some updated details",
      "first_name" => "some updated first_name",
      "last_name" => "some updated last_name",
      "phone1" => "some updated phone1",
      "phone2" => "some updated phone2"
    }
    @invalid_attrs %{
      "details" => nil,
      "first_name" => nil,
      "last_name" => nil,
      "phone1" => nil,
      "phone2" => nil,
      "version" => nil
    }

    @team_attrs %{
      "name" => "Team1"
    }

    @user_create_params %{
      "name" => "John",
      "email" => "test@test.com",
      "password" => "test",
      "password_confirmation" => "test"
    }

    def user_fixture(attrs \\ %{}) do
      active_status = Accounts.get_user_status_by_name(UserStatus.user_status_value_active())
      attrs = Map.merge(attrs, %{"user_status_id" => active_status.id})

      with create_attrs <- Map.merge(@user_create_params, attrs),
           {:ok, user} <- Accounts.create_user(create_attrs) do
        user
      else
        error -> error
      end
    end

    def contact_fixture(attrs \\ %{}) do
      team = team_fixture()

      contact_attrs =
        @valid_attrs
        |> Map.merge(%{"team_id" => team.id})
        |> Map.merge(attrs)

      {:ok, contact} =
        contact_attrs
        |> Contacts.create_contact()

      contact
    end

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@team_attrs)
        |> Accounts.create_team()

      team
    end

    def team_contacts_fixture(team_name, contact_count) do
      team = team_fixture(%{"name" => team_name})

      contacts_attrs =
        for n <- Enum.to_list(1..contact_count) do
          %{
            "first_name" => "Contact-#{n}",
            "version" => 1,
            "phone1" => "0#{n}-12345",
            "team_id" => team.id
          }
        end

      # Create contacts
      contacts =
        Enum.map(contacts_attrs, fn attrs ->
          {:ok, contact} = Contacts.create_contact(attrs)
          contact
        end)

      {team, contacts}
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end

    test "list_team_contacts/1 returns all contacts of a team. Not paginated" do
      # Create a team and add some contacts
      {team1, team_contacts1} = team_contacts_fixture("team1", 3)
      {_team2, _team_contacts2} = team_contacts_fixture("team2", 4)

      # In total we have 7 contacts in the db
      assert Enum.count(Contacts.list_contacts()) == 7

      # Get the list for our team and check the count is right
      team_contacts1_db = Contacts.list_team_contacts(team1.id)
      assert Enum.count(team_contacts1) == Enum.count(team_contacts1_db)

      # Check contact id match
      assert Enum.all?(team_contacts1, fn team_contact ->
               Enum.find(team_contacts1_db, fn contact_db ->
                 team_contact.id == contact_db.id
               end)
             end)

      # Check contact id don't match for contacts from the other team
      assert Enum.all?(team_contacts1, fn team_contact ->
               Enum.find(team_contacts1_db, fn contact_db ->
                 team_contact.id == contact_db.id
               end)
             end)
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      team = team_fixture()

      attrs = Map.merge(@valid_attrs, %{"team_id" => team.id})

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(attrs)
      assert contact.details == "some details"
      assert contact.first_name == "some first_name"
      assert contact.last_name == "some last_name"

      assert contact.phone1 == "some phone1"
      assert contact.phone2 == "some phone2"
      assert contact.version == 1
      assert contact.team_id == team.id
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      assert {:ok, contact} = Contacts.update_contact(contact, @update_attrs)
      assert %Contact{} = contact
      assert contact.details == "some updated details"
      assert contact.first_name == "some updated first_name"
      assert contact.last_name == "some updated last_name"

      assert contact.phone1 == "some updated phone1"
      assert contact.phone2 == "some updated phone2"
      assert contact.version == 1
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end

    test "mark_as_deleted/1 marks contact as deleted" do
      contact = contact_fixture()
      user = user_fixture()

      contact = contact |> Repo.preload([:updated_by])

      assert contact.is_deleted == false
      assert contact.updated_by == nil
      assert {:ok, _updated_contact} = Contacts.mark_as_deleted(contact, user.id)

      updated_contact = Contacts.get_contact!(contact.id)

      assert updated_contact.is_deleted == true
      assert updated_contact.updated_by != nil
      assert updated_contact.updated_by_id == user.id
    end
  end
end
