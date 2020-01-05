defmodule OgahuntWeb.Api.EstateView do
  use OgahuntWeb, :view
  alias OgahuntWeb.Api.EstateView

  alias Ogahunt.Estates.Estate

  def render("index.json", %{estates: estates}) do
    %{estates: render_many(estates, EstateView, "estate.json")}
  end

  def render("show.json", %{estate: estate}) do
    %{estate: render_one(estate, EstateView, "estate.json")}
  end

  def render("estate.json", %{estate: estate}) do
    attrs = %{
      id: estate.id,
      name: estate.name,
      address: estate.address,
      details: estate.details,
      version: estate.version,
      type: estate.estate_type.name,
      status: estate.estate_status.name,
      assigned_to: estate.assigned_to_id,
      inserted_at: estate.inserted_at,
      updated_at: estate.updated_at
    }

    attrs
    |> merge_price(estate)
    |> merge_location(estate)
    |> merge_contact(estate)
    |> merge_images(estate)
  end

  def render("show_estate_images.json", %{estate_id: estate_id, images: images}) do
    %{
      estate_id: estate_id,
      images:
        Enum.map(images, fn image ->
          %{
            id: image.id,
            image_url: image.image_url
          }
        end)
    }
  end

  def render("assignment_success.json", %{estate: _estate}) do
    %{
      success: true
    }
  end

  def render("status_change_success.json", %{estate: _estate}) do
    %{
      success: true
    }
  end

  def render("event_list.json", %{events: estate_events}) do
    %{
      events:
        Enum.map(estate_events, fn event ->
          %{
            id: event.id,
            estate_id: event.estate_id,
            change_type: event.change_type,
            change: event.change,
            by_user_id: event.by_user_id,
            inserted_at: event.inserted_at
          }
        end)
    }
  end

  def render_price(price) do
    %{
      id: price.id,
      amount: price.amount,
      notes: price.notes,
      currency_id: price.currency_id
    }
  end

  def render_location(location) do
    %{
      id: location.id,
      latitude: location.latitude,
      longitude: location.longitude
    }
  end

  def render_contact(contact) do
    %{
      id: contact.id,
      first_name: contact.first_name,
      last_name: contact.last_name,
      phone1: contact.phone1,
      phone2: contact.phone2,
      details: contact.details,
      version: contact.version
    }
  end

  def render_images(images) do
    Enum.map(images, fn image ->
      render_image(image)
    end)
  end

  def render_image(image) do
    {:ok, signed_url, opts} = OgahuntWeb.GCSSigner.signed_url(:get, image.image_url)

    # IO.inspect(opts)
    content_type = Keyword.get(opts, :content_type)
    expires = Keyword.get(opts, :expires)

    %{
      id: image.id,
      image_url: image.image_url,
      signed_image_url: signed_url,
      content_type: content_type,
      expires_tstamp: expires,
      is_deleted: image.is_deleted,
      inserted_at: image.inserted_at
    }
  end

  defp merge_price(attrs, %Estate{current_price: current_price}) when is_nil(current_price) do
    attrs
  end

  defp merge_price(attrs, %Estate{current_price: current_price} = _estate) do
    attrs
    |> Map.merge(%{current_price: render_price(current_price)})
  end

  defp merge_location(attrs, %Estate{location: location}) when is_nil(location) do
    attrs
  end

  defp merge_location(attrs, %Estate{location: location} = _estate) do
    attrs
    |> Map.merge(%{location: render_location(location)})
  end

  defp merge_contact(attrs, %Estate{main_contact: contact}) when is_nil(contact) do
    attrs
  end

  defp merge_contact(attrs, %Estate{main_contact: contact} = _estate) do
    attrs
    |> Map.merge(%{main_contact: render_contact(contact)})
  end

  defp merge_images(attrs, %Estate{images: images}) when is_nil(images) do
    attrs
  end

  defp merge_images(attrs, %Estate{images: images} = _estate) do
    attrs
    |> Map.merge(%{images: render_images(images)})
  end
end
