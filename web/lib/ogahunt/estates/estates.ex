defmodule Ogahunt.Estates do
  @moduledoc """
  The Estates context.
  """
  import Ecto.Changeset
  # alias Ecto.Multi
  import Ecto.Query, warn: false
  alias Ogahunt.Repo

  # alias Ogahunt.Accounts
  alias Ogahunt.Estates
  alias Ogahunt.Estates.Estate
  alias Ogahunt.Estates.Currency
  alias Ogahunt.Estates.EstateStatus
  alias Ogahunt.Estates.EstateType
  alias Ogahunt.Estates.EstatePrice
  alias Ogahunt.Estates.EstateLocation
  alias Ogahunt.Contacts.Contact
  alias Ogahunt.Estates.EstateImage
  alias Ogahunt.Estates.EstateEvent
  alias Ogahunt.Estates.EstateEventType

  def list_unassigned_estates(team_id) do
    query =
      from(
        e in Estate,
        where: e.team_id == ^team_id and is_nil(e.assigned_to_id) and e.is_deleted == false,
        order_by: [desc: :updated_at],
        preload: [:current_price, :location, :main_contact, :estate_status, :estate_type]
      )

    Repo.all(query)
  end

  def list_estates(team_id) do
    query =
      from(
        e in Estate,
        where: e.team_id == ^team_id and e.is_deleted == false,
        order_by: [desc: :updated_at],
        preload: [:current_price, :location, :main_contact, :estate_status, :estate_type, :images]
      )

    Repo.all(query)
  end

  def get_estate!(id), do: Repo.get!(Estate, id)

  def get_fully_loaded(id) do
    Repo.get!(Estate, id)
    |> Repo.preload([
      :current_price,
      :location,
      :main_contact,
      :estate_status,
      :estate_type,
      :images
    ])
  end

  def create_estate(attrs) do
    # 1. save estate: basic, status, type, created_by
    # IO.inspect(attrs)

    attrs = Map.put(attrs, "is_deleted", false)

    estate_changeset =
      %Estate{}
      |> Estate.create_changeset(attrs)

    # Do it manually!
    Repo.transaction(fn ->
      case Repo.insert(estate_changeset) do
        {:ok, estate} ->
          estate_enhancement_price(estate, attrs)

        {:error, changeset} ->
          IO.inspect(changeset)
          Repo.rollback("Failed to insert estate")
      end
    end)
  end

  defp estate_enhancement_price(estate, attrs) do
    case attrs["current_price"] do
      nil ->
        # estate
        estate_enhancement_location(estate, attrs)

      price_attrs ->
        continue_with_price(estate, attrs, price_attrs)
    end
  end

  defp continue_with_price(estate, attrs, price_attrs) do
    currency =
      price_attrs["currency"]
      |> get_currency_by_code()

    price_attrs =
      Map.merge(price_attrs, %{"estate_id" => estate.id, "currency_id" => currency.id})

    # IO.inspect(price_attrs)

    estate_price_cs =
      %EstatePrice{}
      |> EstatePrice.changeset(price_attrs)

    case Repo.insert(estate_price_cs) do
      {:ok, estate_price} ->
        update_price_cs =
          estate
          |> change(%{current_price_id: estate_price.id})

        case Repo.update(update_price_cs) do
          {:ok, updated_estate} ->
            # continue with location -> pass attrs
            estate_enhancement_location(updated_estate, attrs)

          {:error, changeset} ->
            IO.inspect(changeset)
            Repo.rollback("Failed to update estate with the price")
        end

      {:error, changeset} ->
        IO.inspect(changeset)
        Repo.rollback("Failed to insert estate price")
    end
  end

  defp estate_enhancement_location(estate, attrs) do
    case attrs["location"] do
      nil ->
        estate_enhancement_contact(estate, attrs)

      location_attrs ->
        continue_with_location(estate, attrs, location_attrs)
    end
  end

  defp continue_with_location(estate, attrs, location_attrs) do
    # 3. location: save&associate or pass

    location_attrs = Map.merge(location_attrs, %{"estate_id" => estate.id})

    location_cs =
      %EstateLocation{}
      |> EstateLocation.changeset(location_attrs)

    case Repo.insert(location_cs) do
      {:ok, location} ->
        associate_estate_to_location(estate, location, attrs)

      {:error, changeset} ->
        IO.inspect(changeset)
        Repo.rollback("Failed to insert location")
    end
  end

  defp associate_estate_to_location(estate, location, attrs) do
    estate_location_cs = estate |> change(%{location_id: location.id})

    case Repo.update(estate_location_cs) do
      {:ok, estate_updated} ->
        estate_enhancement_contact(estate_updated, attrs)

      {:error, changeset} ->
        IO.inspect(changeset)
        Repo.rollback("Failed to insert location")
    end
  end

  defp estate_enhancement_contact(estate, attrs) do
    case attrs["main_contact"] do
      nil ->
        estate

      contact_attrs ->
        continue_with_contact(estate, attrs, contact_attrs)
    end
  end

  defp continue_with_contact(estate, _attrs, %{"id" => contact_id} = _contact_attrs) do
    associate_contact_estate(estate, contact_id)
  end

  defp continue_with_contact(estate, _attrs, contact_attrs) do
    # Add team_id to contact before inserting
    contact_attrs = Map.merge(contact_attrs, %{"team_id" => estate.team_id})

    contact_cs = Contact.create_changeset(contact_attrs)

    case Repo.insert(contact_cs) do
      {:ok, contact} ->
        associate_contact_estate(estate, contact.id)

      {:error, changeset} ->
        IO.inspect(changeset)
        Repo.rollback("Failed to insert contact")
    end
  end

  defp associate_contact_estate(estate, contact_id) do
    estate_contact_cs =
      estate
      |> change(%{main_contact_id: contact_id})

    case Repo.update(estate_contact_cs) do
      {:ok, updated_estate} ->
        updated_estate

      {:error, changeset} ->
        IO.inspect(changeset)
        Repo.rollback("Failed to update estate with  main contact")
    end
  end

  def update_location(%Estate{} = estate, attrs) do
    case attrs["location"] do
      %{"latitude" => _latitude, "longitude" => _longitude} = current_location ->
        update_with_current_location(estate, current_location, attrs["updated_by_id"])

      _ ->
        estate
    end
  end

  def update_with_current_location(
        estate,
        %{"latitude" => latitude, "longitude" => longitude} = new_location,
        updated_by_id
      ) do
    estate = Repo.preload(estate, [:location])

    case estate.location do
      nil ->
        # Set
        create_and_set_estate_current_location(estate, new_location, updated_by_id)

      estate_current_location ->
        if estate_current_location.latitude == latitude &&
             estate_current_location.longitude == longitude do
          # Same location, skip
          # estate = Repo.preload(estate, [:current_price])
          {:ok, estate}
        else
          # Append and set
          update_estate_current_location(
            estate,
            estate_current_location,
            new_location,
            updated_by_id
          )
        end
    end
  end

  def update_estate_current_location(
        estate,
        %EstateLocation{} = estate_current_location,
        %{"latitude" => latitude, "longitude" => longitude} = _new_location,
        updated_by_id
      ) do
    {:ok, _} =
      estate_current_location
      |> change(%{latitude: latitude, longitude: longitude})
      |> Repo.update()

    estate
    |> change(%{updated_by_id: updated_by_id, version: estate.version + 1})
    |> Repo.update()
  end

  def create_and_set_estate_current_location(
        estate,
        %{"latitude" => _latitude, "longitude" => _longitude} = current_location,
        updated_by_id
      ) do
    current_location = Map.merge(current_location, %{"estate_id" => estate.id})

    {:ok, estate_location} =
      %EstateLocation{}
      |> EstateLocation.changeset(current_location)
      |> Repo.insert()

    set_estate_current_location(estate, estate_location, updated_by_id)
  end

  def set_estate_current_location(estate, %EstateLocation{} = location, updated_by_id) do
    estate
    |> change(%{
      location_id: location.id,
      updated_by_id: updated_by_id,
      version: estate.version + 1
    })
    |> Repo.update()
  end

  def update_price(%Estate{} = estate, attrs) do
    case attrs["current_price"] do
      %{"amount" => _amount} = current_price ->
        update_with_current_price(estate, current_price, attrs["updated_by_id"])

      _ ->
        bump_estate_version(estate)
    end
  end

  def bump_estate_version(%Estate{} = estate) do
    estate
    |> change(%{version: estate.version + 1})
    |> Repo.update()
  end

  def update_with_current_price(
        estate,
        %{"amount" => amount} = current_price,
        updated_by_id
      ) do
    estate = Repo.preload(estate, [:current_price])

    case estate.current_price do
      nil ->
        # Append and set
        append_and_set_current_price(estate, current_price, updated_by_id)

      estate_current_price ->
        if estate_current_price.amount == Decimal.new(amount) do
          # Same price, skip
          # estate = Repo.preload(estate, [:current_price])
          # {:ok, estate}
          bump_estate_version(estate)
        else
          # Append and set
          append_and_set_current_price(estate, current_price, updated_by_id)
        end
    end
  end

  def append_and_set_current_price(
        estate,
        %{"amount" => _amount, "currency" => currency_code} = current_price,
        updated_by_id
      ) do
    # :amount, :currency_id, :estate_id
    currency = Estates.get_currency_by_code(currency_code)

    current_price =
      Map.merge(current_price, %{"estate_id" => estate.id, "currency_id" => currency.id})

    {:ok, estate_price} =
      %EstatePrice{}
      |> EstatePrice.changeset(current_price)
      |> Repo.insert()

    estate
    |> change(%{
      current_price_id: estate_price.id,
      updated_by_id: updated_by_id,
      version: estate.version + 1
    })
    # |> Estate.update_changeset(estate_attrs)
    |> Repo.update()
  end

  def update_estate(%Estate{} = estate, attrs) do
    estate
    |> Estate.update_changeset(attrs)
    |> Repo.update()
  end

  def mark_as_deleted(%Estate{} = estate, user_id) do
    estate
    |> Estate.update_changeset(%{is_deleted: true, updated_by_id: user_id})
    |> Repo.update!()
  end

  def delete_estate(%Estate{} = estate) do
    Repo.delete(estate)
  end

  def change_estate(%Estate{} = estate) do
    Estate.update_changeset(estate, %{})
  end

  def get_estate_status_by_name(name) do
    Repo.get_by(EstateStatus, name: name)
  end

  def get_estate_type_by_name(name) do
    Repo.get_by(EstateType, name: name)
  end

  def all_estate_type() do
    Repo.all(EstateType)
  end

  def get_currency_by_code(nil) do
    Repo.get_by!(Currency, code: "USD")
  end

  def get_currency_by_code(code) do
    Repo.get_by!(Currency, code: code)
  end

  # Appends an image and bumps estate version
  # Obs.: Maybe we need to do it in a transaction
  def append_image(estate_id, image_attr) do
    image_attr = Map.merge(image_attr, %{"estate_id" => estate_id})

    {:ok, saved_image} =
      %EstateImage{}
      |> EstateImage.changeset(image_attr)
      |> Repo.insert()

    {:ok, saved_image}
  end

  def append_images(_estate_id, []), do: {:ok, []}

  def append_images(estate_id, images) when is_list(images) do
    Repo.transaction(fn ->
      case insert_images(estate_id, [], images) do
        {:ok, resimages} ->
          resimages

        {:error, changeset} ->
          IO.inspect(changeset)
          Repo.rollback("Failed to insert images")
      end
    end)
  end

  def insert_images(_estate_id, images, []) do
    {:ok, images}
  end

  def insert_images(estate_id, images, [image_attr | rest_attrs]) do
    image_attr = Map.merge(image_attr, %{"estate_id" => estate_id})
    cs = %EstateImage{} |> EstateImage.changeset(image_attr)

    IO.inspect(cs)

    case Repo.insert(cs) do
      {:ok, estate_image} ->
        insert_images(estate_id, [estate_image | images], rest_attrs)

      {:error, cs} ->
        {:error, cs}
    end
  end

  def assign_estate_to(estate_id, assigned_by, assign_to) do
    now = NaiveDateTime.utc_now()

    with estate <- get_estate!(estate_id) do
      estate
      |> change(%{assigned_to_id: assign_to, assigned_by_id: assigned_by, assigned_at: now})
      |> Repo.update()
    end
  end

  def change_estate_status(estate_id, status_name, user_id) do
    case Estates.get_estate_status_by_name(status_name) do
      nil ->
        {:error, :invalid_status}

      status ->
        change_estate_status_using_id(estate_id, status.id, user_id)
    end
  end

  defp change_estate_status_using_id(estate_id, status_id, user_id) do
    with estate <- get_estate!(estate_id),
         new_version <- estate.version + 1 do
      estate
      |> change(%{estate_status_id: status_id, version: new_version, updated_by_id: user_id})
      |> Repo.update()
    end
  end

  def latest_estate_changes(team_id) do
    query =
      from(
        ee in EstateEvent,
        where: ee.team_id == ^team_id,
        order_by: [desc: :inserted_at],
        limit: 50
      )

    Repo.all(query)
  end

  def append_create_event(estate, user_id) do
    change_type = EstateEventType.estate_event_type_value_created()

    change = %{
      "element" => "estate",
      "action" => "created"
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_delete_event(estate, user_id) do
    change_type = EstateEventType.estate_event_type_value_deleted()

    change = %{
      "element" => "estate",
      "action" => "deleted",
      "name" => estate.name
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_assign_event(estate, nil) do
    change_type = EstateEventType.estate_event_type_value_unassigned()

    change = %{
      "element" => "estate",
      "action" => "unassigned"
    }

    append_event(estate.id, estate.team_id, change, change_type, estate.assigned_by_id)
  end

  def append_assign_event(estate, assigned_to_id) when not is_nil(assigned_to_id) do
    change_type = EstateEventType.estate_event_type_value_assigned()

    change = %{
      "element" => "estate",
      "action" => "assigned",
      "assigned_to" => assigned_to_id
    }

    append_event(estate.id, estate.team_id, change, change_type, estate.assigned_by_id)
  end

  def append_status_event(estate, "archived", user_id) do
    change_type = EstateEventType.estate_event_type_value_archived()

    change = %{
      "element" => "estate",
      "action" => "archive"
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_status_event(estate, "open", user_id) do
    change_type = EstateEventType.estate_event_type_value_open()

    change = %{
      "element" => "estate",
      "action" => "open"
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_location_change_event(estate, location, user_id) do
    change_type = EstateEventType.estate_event_type_value_location_change()

    change = %{
      "element" => "estate",
      "action" => "location",
      "location" => location
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_image_added_event(estate, resource_name, user_id) do
    change_type = EstateEventType.estate_event_type_value_image_added()

    change = %{
      "element" => "estate",
      "action" => "image",
      "resource_name" => resource_name
    }

    append_event(estate.id, estate.team_id, change, change_type, user_id)
  end

  def append_estate_update(
        original_estate,
        estate,
        %{"current_price" => current_price} = _estate_params,
        user_id
      ) do
    change_type = EstateEventType.estate_event_type_value_details_updated()

    changes = build_changes_map(original_estate, estate)

    changes = build_price_change(changes, original_estate, current_price)

    change = %{
      "element" => "estate",
      "action" => "details_change",
      "changes" => changes
    }

    if changes == [] do
      {:ok, :no_changes}
    else
      append_event(estate.id, estate.team_id, change, change_type, user_id)
    end
  end

  defp build_price_change(changes, original_estate, %{"amount" => new_price} = _current_price) do
    old_price = original_estate.current_price

    cond do
      is_nil(old_price) and is_nil(new_price) ->
        changes

      is_nil(old_price) and !is_nil(new_price) ->
        [%{key: :current_price, type: :set_value, value: Decimal.new(new_price)} | changes]

      !is_nil(old_price) and is_nil(new_price) ->
        [%{key: :current_price, type: :unset_value} | changes]

      old_price.amount == Decimal.new(new_price) ->
        changes

      true ->
        [%{key: :current_price, type: :change, value: Decimal.new(new_price)} | changes]
    end
  end

  defp build_price_change(changes, _original_estate, _current_price) do
    changes
  end

  defp build_changes_map(original_estate, estate) do
    # name, type, address, contact, price, details
    # added, changed
    detail_keys = [
      :name,
      :estate_type_id,
      :address,
      :main_contact_id,
      :details
    ]

    Enum.reduce(detail_keys, [], fn key, acc ->
      case identify_change(original_estate, estate, key) do
        {:no_change, _reason} ->
          acc

        {:set_value, value} ->
          [%{key: key, type: :set_value, value: value} | acc]

        {:unset_value, _reason} ->
          [%{key: key, type: :unset_value} | acc]

        {:change, value} ->
          [%{key: key, type: :change, value: value} | acc]
      end
    end)
  end

  defp identify_change(%Estate{} = original_estate, %Estate{} = estate, key) do
    original = Map.get(original_estate, key)
    new = Map.get(estate, key)

    IO.inspect("Old: '#{original}' New: '#{new}'")

    cond do
      is_nil(original) and is_nil(new) ->
        {:no_change, :both_nil}

      original == new ->
        {:no_change, :both_set}

      is_nil(original) and !is_nil(new) ->
        {:set_value, new}

      !is_nil(original) and is_nil(new) ->
        {:unset_value, :nil_value}

      true ->
        {:change, new}
    end
  end

  defp append_event(estate_id, team_id, %{} = change, change_type, user_id) do
    # Create changeset
    %EstateEvent{}
    |> EstateEvent.changeset(%{
      estate_id: estate_id,
      team_id: team_id,
      by_user_id: user_id,
      change_type: change_type,
      change: change
    })
    |> Repo.insert()
  end

  def latest_estate_events(estate_id) do
    from(
      ev in EstateEvent,
      where: ev.estate_id == ^estate_id,
      order_by: [desc: :inserted_at],
      limit: 50
    )
    |> Repo.all()
  end
end
