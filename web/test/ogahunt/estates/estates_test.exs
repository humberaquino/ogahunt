defmodule Ogahunt.EstatesTest do
  use Ogahunt.DataCase

  alias Ogahunt.Estates
  alias Ogahunt.Estates.EstateStatus
  alias Ogahunt.Estates.EstateType
  # alias Ogahunt.Estates.EstateEvent
  alias Ogahunt.Estates.EstateEventType
  alias Ogahunt.Accounts.UserStatus
  alias Ogahunt.Accounts
  alias Ogahunt.Contacts.Contact
  alias Ogahunt.Contacts

  describe "estates" do
    alias Ogahunt.Estates.Estate

    @valid_attrs %{
      "address" => "some address",
      "details" => "some details",
      "name" => "some name"
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

    @team_create_params %{"name" => "team1"}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        Map.merge(@team_create_params, attrs)
        |> Accounts.create_team()

      team
    end

    def basic_estate_attrs(attrs \\ %{}) do
      # User for created_by_id
      user = user_fixture()
      # team_id -> Team
      team = team_fixture()
      # estate_status_id -> EstateStatus
      open_estate_status =
        Estates.get_estate_status_by_name(EstateStatus.estate_status_value_open())

      # estate_type_id -> EstateType
      house_estate_type = Estates.get_estate_type_by_name(EstateType.estate_type_value_house())

      Map.merge(attrs, %{
        "team_id" => team.id,
        "estate_status_id" => open_estate_status.id,
        "estate_type_id" => house_estate_type.id,
        "created_by_id" => user.id
      })
    end

    def estate_attrs(team_id, user_id, attrs \\ %{}) do
      # estate_status_id -> EstateStatus
      open_estate_status =
        Estates.get_estate_status_by_name(EstateStatus.estate_status_value_open())

      # estate_type_id -> EstateType
      house_estate_type = Estates.get_estate_type_by_name(EstateType.estate_type_value_house())

      Map.merge(attrs, %{
        "team_id" => team_id,
        "estate_status_id" => open_estate_status.id,
        "estate_type_id" => house_estate_type.id,
        "created_by_id" => user_id
      })
    end

    @contact_valid_attrs %{
      "details" => "some details",
      "first_name" => "some first_name",
      "last_name" => "some last_name",
      "phone1" => "some phone1",
      "phone2" => "some phone2"
    }

    def contact_fixture(attrs \\ %{}) do
      team = team_fixture()

      contact_attrs =
        @contact_valid_attrs
        |> Map.merge(%{"team_id" => team.id})
        |> Map.merge(attrs)

      {:ok, contact} =
        contact_attrs
        |> Contacts.create_contact()

      contact
    end

    @location_attrs %{
      "location" => %{
        "latitude" => "12.3456",
        "longitude" => "7.890"
      }
    }

    @price_attrs %{
      "current_price" => %{
        "amount" => "100000",
        "currency" => "USD"
      }
    }

    @contact_attrs %{
      "main_contact" => %{
        "first_name" => "Mike",
        "last_name" => "Jordan",
        "phone1" => "123456",
        "phone2" => nil,
        "details" => "Is a test detail"
      }
    }

    def create_estate(merge_list) do
      attrs = basic_estate_attrs()

      attrs =
        Enum.reduce(merge_list, attrs, fn attr, attrs ->
          Map.merge(attrs, attr)
        end)

      {:ok, _estate} =
        attrs
        # |> Enum.into(@valid_attrs)
        |> Estates.create_estate()
    end

    def estate_fixture(attrs \\ %{}) do
      {:ok, estate} = create_estate(attrs)
      estate
    end

    def estate_fixture(team_id, user_id, attrs) do
      enhanced_attrs = estate_attrs(team_id, user_id, attrs)
      attrs = Map.merge(enhanced_attrs, %{"team_id" => team_id, "user_id" => user_id})

      {:ok, estate} =
        attrs
        |> Estates.create_estate()

      estate
    end

    test "list_unassigned_estates/1 returns all estates for a particular team" do
      user = user_fixture()
      # Create team 1 & add a estate
      team1 = team_fixture(%{"name" => "team1"})
      estate_team1 = estate_fixture(team1.id, user.id, %{"name" => "Estate 1. team 1"})

      # Create team 2 & add a estate
      team2 = team_fixture(%{"name" => "team2"})
      estate_team2 = estate_fixture(team2.id, user.id, %{"name" => "Estate 1. Team 2"})

      # Get list from team 1. Only its estate should be there
      specific_attrs_team1_estates =
        Estates.list_unassigned_estates(team1.id)
        |> Enum.map(fn estate ->
          Map.drop(estate, [
            :current_price,
            :location,
            :main_contact,
            :estate_status,
            :estate_type
          ])
        end)

      estate_team1 =
        estate_team1
        |> Map.drop([:current_price, :location, :main_contact, :estate_status, :estate_type])

      assert specific_attrs_team1_estates == [estate_team1]

      specific_attrs_team2_estates =
        Estates.list_unassigned_estates(team2.id)
        |> Enum.map(fn estate ->
          Map.drop(estate, [
            :current_price,
            :location,
            :main_contact,
            :estate_status,
            :estate_type
          ])
        end)

      estate_team2 =
        estate_team2
        |> Map.drop([:current_price, :location, :main_contact, :estate_status, :estate_type])

      assert specific_attrs_team2_estates == [estate_team2]
    end

    test "list_estates/1 returns all estates for a particular team" do
      user = user_fixture()
      # Create team 1 & add a estate
      team1 = team_fixture(%{"name" => "team1"})
      estate_team1 = estate_fixture(team1.id, user.id, %{"name" => "Estate 1. team 1"})

      # Create team 2 & add a estate
      team2 = team_fixture(%{"name" => "team2"})
      estate_team2 = estate_fixture(team2.id, user.id, %{"name" => "Estate 1. Team 2"})

      drop_list = [
        :current_price,
        :location,
        :main_contact,
        :estate_type,
        :images,
        :estate_status
      ]

      # Get list from team 1. Only its estate should be there
      specific_attrs_team1_estates =
        Estates.list_estates(team1.id)
        |> Enum.map(fn estate ->
          Map.drop(estate, drop_list)
        end)

      estate_team1 =
        estate_team1
        |> Map.drop(drop_list)

      assert specific_attrs_team1_estates == [estate_team1]

      specific_attrs_team2_estates =
        Estates.list_estates(team2.id)
        |> Enum.map(fn estate ->
          Map.drop(estate, drop_list)
        end)

      estate_team2 =
        estate_team2
        |> Map.drop(drop_list)

      assert specific_attrs_team2_estates == [estate_team2]
    end

    test "create_estate/1 with valid data creates a estate: basic" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price])

      assert estate_db.current_price == nil
    end

    test "create_estate/1 with valid data creates a estate: basic + an event" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price])

      assert estate_db.current_price == nil

      # Add estate_event and associate
      user = user_fixture(%{"email" => "anewone@gmail.com"})
      {:ok, _estate_event} = Estates.append_create_event(estate_db, user.id)
      estate_with_events = Repo.preload(estate_db, [:events])
      assert Enum.count(estate_with_events.events) == 1
    end

    test "create_estate/1 with valid data creates a estate: full enhanced" do
      assert {:ok, %Estate{} = estate} =
               create_estate([@valid_attrs, @location_attrs, @price_attrs, @contact_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Find with preload of price
      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price, :location])

      # IO.inspect(estate_db)
      assert estate_db.current_price.amount == Decimal.new("100000.00")
      assert !is_nil(estate_db.location)
      assert !is_nil(estate_db.main_contact_id)
    end

    test "create_estate/1 with valid data creates a estate: contact and location enhanced" do
      assert {:ok, %Estate{} = estate} =
               create_estate([@valid_attrs, @location_attrs, @contact_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Find with preload of price
      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price, :location])

      # IO.inspect(estate_db)
      assert is_nil(estate_db.current_price_id)
      assert !is_nil(estate_db.location)
      assert !is_nil(estate_db.main_contact_id)
    end

    test "create_estate/1 with valid data creates a estate: contact only" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @contact_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Find with preload of price
      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price, :location, :main_contact])

      # IO.inspect(estate_db)
      assert is_nil(estate_db.current_price_id)
      assert is_nil(estate_db.location)
      assert !is_nil(estate_db.main_contact_id)

      # Get the contact from the DB
      contact = Repo.get!(Contact, estate_db.main_contact_id)
      assert !is_nil(contact)

      assert !is_nil(estate_db.main_contact)
    end

    test "create_estate/1 with valid data creates a estate: price only" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @price_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Find with preload of price
      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price, :location])

      # IO.inspect(estate_db)
      assert !is_nil(estate_db.current_price_id)
      assert is_nil(estate_db.location)
      assert is_nil(estate_db.main_contact_id)
    end

    test "create_estate/1 with valid data creates a estate: location only" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @location_attrs])

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Find with preload of price
      estate_db =
        Repo.get(Estate, estate.id)
        |> Repo.preload([:current_price, :location])

      # IO.inspect(estate_db)
      assert is_nil(estate_db.current_price_id)
      assert !is_nil(estate_db.location)
      assert is_nil(estate_db.main_contact_id)
    end

    test "update_price/2 updates the price of a estate with a new one. Not existing before" do
      # Create a estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @location_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      # Make sure no price exist yet
      assert is_nil(estate.current_price_id)

      amount = "200000.00"
      # Update the price (minimum params provided)
      estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "current_price" => %{
          "amount" => amount,
          "currency" => "USD"
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_price(estate, estate_params)

      assert updated_estate.id == estate.id

      db_estate = Estates.get_estate!(estate.id) |> Repo.preload([:current_price, :prices])

      assert !is_nil(db_estate.current_price_id)
      assert db_estate.current_price.amount == Decimal.new(amount)

      # Should be only onw price in the list

      assert Enum.count(db_estate.prices) == 1
    end

    test "update_price/2 updates the price of a estate with a new one. One existing before but price changed" do
      # Create a estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @location_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      # Make sure no price exist yet
      assert is_nil(estate.current_price_id)

      amount = "200000.00"
      # Update the price (minimum params provided)
      estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "current_price" => %{
          "amount" => amount,
          "currency" => "USD"
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_price(estate, estate_params)

      assert updated_estate.id == estate.id

      db_estate = Estates.get_estate!(estate.id) |> Repo.preload([:current_price, :prices])

      assert !is_nil(db_estate.current_price_id)
      assert db_estate.current_price.amount == Decimal.new(amount)

      # Should be only onw price in the list
      assert Enum.count(db_estate.prices) == 1

      ###### set price again

      new_amount = "300000.00"
      # Update the price (minimum params provided)
      new_estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "current_price" => %{
          "amount" => new_amount,
          "currency" => "USD"
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_price(db_estate, new_estate_params)

      assert updated_estate.id == db_estate.id

      new_db_estate = Estates.get_estate!(db_estate.id) |> Repo.preload([:current_price, :prices])

      assert !is_nil(new_db_estate.current_price_id)
      assert new_db_estate.current_price.amount == Decimal.new(new_amount)

      # Whe should have 2 prices at this point
      assert Enum.count(new_db_estate.prices) == 2
    end

    test "update_price/2 updates the price of a estate with a new one. One existing before but price DIDNT change" do
      # Create a estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @location_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      # Make sure no price exist yet
      assert is_nil(estate.current_price_id)

      amount = "200000.00"
      # Update the price (minimum params provided)
      estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "current_price" => %{
          "amount" => amount,
          "currency" => "USD"
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_price(estate, estate_params)

      assert updated_estate.id == estate.id

      db_estate = Estates.get_estate!(estate.id) |> Repo.preload([:current_price, :prices])

      assert !is_nil(db_estate.current_price_id)
      assert db_estate.current_price.amount == Decimal.new(amount)

      # Should be only onw price in the list
      assert Enum.count(db_estate.prices) == 1

      ###### set price again

      # same amount
      new_amount = amount
      # Update the price (minimum params provided)
      new_estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "current_price" => %{
          "amount" => new_amount,
          "currency" => "USD"
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_price(db_estate, new_estate_params)

      assert updated_estate.id == db_estate.id

      new_db_estate = Estates.get_estate!(db_estate.id) |> Repo.preload([:current_price, :prices])

      assert !is_nil(new_db_estate.current_price_id)
      assert new_db_estate.current_price.amount == Decimal.new(new_amount)

      # Whe should have 2 prices at this point
      assert Enum.count(new_db_estate.prices) == 1
    end

    test "update_location/2 updates the location of a estate with a new one. Not existing before" do
      # Create a estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      # Make sure no price exist yet
      assert is_nil(estate.current_price_id)

      latitude = 123.0
      longitude = 456.0
      # Update the price (minimum params provided)
      estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "location" => %{
          "latitude" => latitude,
          "longitude" => longitude
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_location(estate, estate_params)

      assert updated_estate.id == estate.id

      db_estate = Estates.get_estate!(estate.id) |> Repo.preload([:location])

      assert !is_nil(db_estate.location_id)
      assert db_estate.location.latitude == latitude
      assert db_estate.location.longitude == longitude
    end

    test "update_location/2 updates the location of a estate with a new one. Already existing" do
      # Create a estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs, @location_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      # Make sure no price exist yet
      assert is_nil(estate.current_price_id)

      latitude = 123.0
      longitude = 456.0
      # Update the price (minimum params provided)
      estate_params = %{
        "estate_id" => estate.id,
        "updated_by_id" => user.id,
        "location" => %{
          "latitude" => latitude,
          "longitude" => longitude
        }
      }

      {:ok, %Estate{} = updated_estate} = Estates.update_location(estate, estate_params)

      assert updated_estate.id == estate.id

      db_estate = Estates.get_estate!(estate.id) |> Repo.preload([:location])

      assert !is_nil(db_estate.location_id)
      assert db_estate.location.latitude == latitude
      assert db_estate.location.longitude == longitude
    end

    test "assign_estate_to/2 assigns a estate to an user. Estate was unassigned" do
      # Create estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      assigner = user_fixture(%{"email" => "anewone@gmail.com"})
      assigned_to = user_fixture(%{"email" => "anewone2@gmail.com"})

      # Check estate is unassigned
      assert is_nil(estate.assigned_to_id)
      assert is_nil(estate.assigned_by_id)
      assert is_nil(estate.assigned_at)

      # Assign and check
      assert {:ok, updated_estate_db} =
               Estates.assign_estate_to(estate.id, assigner.id, assigned_to.id)

      # updated_estate_db = Estates.get_estate!(estate.id)

      assert updated_estate_db.assigned_to_id == assigned_to.id
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)
    end

    test "assign_estate_to/2 assigns a estate to an user. Estate was assigned and now is changed" do
      # Create estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      assigner = user_fixture(%{"email" => "anewone@gmail.com"})
      assigned_to = user_fixture(%{"email" => "anewone2@gmail.com"})
      new_assigned_to = user_fixture(%{"email" => "anewone3@gmail.com"})

      # Check estate is unassigned
      assert is_nil(estate.assigned_to_id)
      assert is_nil(estate.assigned_by_id)
      assert is_nil(estate.assigned_at)

      # Assign and check
      assert {:ok, updated_estate_db} =
               Estates.assign_estate_to(estate.id, assigner.id, assigned_to.id)

      # updated_estate_db = Estates.get_estate!(estate.id)

      assert updated_estate_db.assigned_to_id == assigned_to.id
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)

      # Now we have the estate assigned. Reassign to another one
      # Assign and check
      assert {:ok, updated_estate_db2} =
               Estates.assign_estate_to(estate.id, assigner.id, new_assigned_to.id)

      # updated_estate_db = Estates.get_estate!(estate.id)

      assert updated_estate_db2.assigned_to_id == new_assigned_to.id
      assert updated_estate_db2.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db2.assigned_at)
    end

    test "assign_estate_to/2 UNassigns a estate from an user. Estate was assigned" do
      # Create estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      assigner = user_fixture(%{"email" => "anewone@gmail.com"})
      assigned_to = user_fixture(%{"email" => "anewone2@gmail.com"})

      # Check estate is unassigned
      assert is_nil(estate.assigned_to_id)
      assert is_nil(estate.assigned_by_id)
      assert is_nil(estate.assigned_at)

      # Assign and check
      assert {:ok, updated_estate_db} =
               Estates.assign_estate_to(estate.id, assigner.id, assigned_to.id)

      # updated_estate_db = Estates.get_estate!(estate.id)

      assert updated_estate_db.assigned_to_id == assigned_to.id
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)

      # Unassign now

      # Assign and check
      assert {:ok, updated_estate_db} = Estates.assign_estate_to(estate.id, assigner.id, nil)

      # updated_estate_db = Estates.get_estate!(estate.id)

      assert updated_estate_db.assigned_to_id == nil
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)
    end

    test "change_estate_status/3 sets the status correctly to archived" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      status = "archived"
      {:ok, updated_estate} = Estates.change_estate_status(estate.id, status, user.id)

      assert !is_nil(updated_estate)
    end

    test "change_estate_status/3 fails to set an invalid status" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      status = "invalid123"
      assert {:error, :invalid_status} = Estates.change_estate_status(estate.id, status, user.id)
    end

    test "mark_as_deleted/1 with valid data creates a estate and marks is as deleted" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Check estate exists
      estate_db = Repo.get(Estate, estate.id)
      assert estate_db
      refute estate_db.is_deleted

      # Delete and check is marked as one
      estate_deleted = Estates.mark_as_deleted(estate, user.id)
      assert estate_deleted.is_deleted
    end

    test "mark_as_deleted/1 with valid data creates a estate and marks is as deleted. Add event" do
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      user = user_fixture(%{"email" => "anewone@gmail.com"})

      assert estate.address == "some address"
      assert estate.details == "some details"
      assert estate.name == "some name"
      assert estate.version == 1

      # Check estate exists
      estate_db = Repo.get(Estate, estate.id)
      assert estate_db
      refute estate_db.is_deleted

      # Delete and check is marked as one
      estate_deleted = Estates.mark_as_deleted(estate, user.id)
      assert estate_deleted.is_deleted

      # Mark as deleted and check if it worked
      {:ok, estate_event} = Estates.append_delete_event(estate_deleted, user.id)
      assert estate_event.change_type == EstateEventType.estate_event_type_value_deleted()
      assert estate_event.team_id == estate_deleted.team_id
      assert estate_event.by_user_id == user.id
      assert estate_event.estate_id == estate_deleted.id
    end

    test "assign_estate_to/2 assigns a estate to an user. Estate was unassigned. Record event" do
      # Create estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      assigner = user_fixture(%{"email" => "anewone@gmail.com"})
      assigned_to = user_fixture(%{"email" => "anewone2@gmail.com"})

      # Check estate is unassigned
      assert is_nil(estate.assigned_to_id)
      assert is_nil(estate.assigned_by_id)
      assert is_nil(estate.assigned_at)

      # Assign and check
      assert {:ok, updated_estate_db} =
               Estates.assign_estate_to(estate.id, assigner.id, assigned_to.id)

      assert updated_estate_db.assigned_to_id == assigned_to.id
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)

      {:ok, assign_event} =
        Estates.append_assign_event(updated_estate_db, updated_estate_db.assigned_to_id)

      assert assign_event.change

      assert assign_event.change == %{
               "element" => "estate",
               "action" => "assigned",
               "assigned_to" => updated_estate_db.assigned_to_id
             }
    end

    test "assign_estate_to/2 assigns a estate to an user then unassign. Record the last one and check" do
      # Create estate
      assert {:ok, %Estate{} = estate} = create_estate([@valid_attrs])
      assigner = user_fixture(%{"email" => "anewone@gmail.com"})
      assigned_to = user_fixture(%{"email" => "anewone2@gmail.com"})

      # Check estate is unassigned
      assert is_nil(estate.assigned_to_id)
      assert is_nil(estate.assigned_by_id)
      assert is_nil(estate.assigned_at)

      # Assign and check
      assert {:ok, updated_estate_db} =
               Estates.assign_estate_to(estate.id, assigner.id, assigned_to.id)

      assert updated_estate_db.assigned_to_id == assigned_to.id
      assert updated_estate_db.assigned_by_id == assigner.id
      assert !is_nil(updated_estate_db.assigned_at)

      # prev_assigned_to = updated_estate_db.assigned_to_id
      # prev_assigned_by = updated_estate_db.assigned_by_id

      # Unassign and check
      assert {:ok, updated_estate_db} = Estates.assign_estate_to(estate.id, assigner.id, nil)
      assert updated_estate_db.assigned_to_id == nil

      {:ok, unassign_event} =
        Estates.append_assign_event(updated_estate_db, updated_estate_db.assigned_to_id)

      assert unassign_event.change

      assert unassign_event.change == %{
               "element" => "estate",
               "action" => "unassigned"
             }
    end

    test "mark_as_deleted/1 can't mark contact as deleted because an active estate exists" do
      contact = contact_fixture()
      user = user_fixture(%{"email" => "updater@test.com"})
      team1 = team_fixture(%{"name" => "team1"})
      estate = estate_fixture(team1.id, user.id, %{"name" => "Estate 1. team 1"})

      assert estate.main_contact_id == nil

      {:ok, _updated_estate} =
        Estates.update_estate(estate, %{
          "main_contact_id" => contact.id,
          "updated_by_id" => user.id
        })

      contact = contact |> Repo.preload([:updated_by])
      assert contact.is_deleted == false
      assert contact.updated_by == nil

      # Try to delete
      assert {:error, _reason} = Contacts.mark_as_deleted(contact, user.id)

      dbcontact = Contacts.get_contact!(contact.id) |> Repo.preload([:updated_by])

      assert dbcontact.is_deleted == false
      assert dbcontact.updated_by == nil
    end
  end
end
