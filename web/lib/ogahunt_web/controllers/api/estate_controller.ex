defmodule OgahuntWeb.Api.EstateController do
  use OgahuntWeb, :controller

  alias Ogahunt.Estates
  alias Ogahunt.Estates.Estate
  alias Ogahunt.Estates.EstateStatus
  alias Ogahunt.Repo
  # alias Ogahunt.AuthPolicy

  action_fallback(OgahuntWeb.FallbackController)

  def index(conn, %{"team_id" => team_id}) do
    estates = Estates.list_estates(team_id)
    render(conn, "index.json", estates: estates)
  end

  def create(conn, %{"team_id" => team_id, "estate" => estate_params}) do
    user = conn.assigns[:user]

    estate_params = Map.merge(estate_params, %{"team_id" => team_id, "created_by_id" => user.id})

    # Open by default
    status_name = EstateStatus.estate_status_value_open()
    type_name = estate_params["type"]

    with type <- Estates.get_estate_type_by_name(type_name),
         status <- Estates.get_estate_status_by_name(status_name),
         estate_params <-
           Map.merge(estate_params, %{
             "estate_status_id" => status.id,
             "estate_type_id" => type.id
           }),
         {:ok, %Estate{} = estate} <- Estates.create_estate(estate_params),
         {:ok, _estate_event} <- Estates.append_create_event(estate, user.id) do
      # Handle the images now
      estate_db = Estates.get_fully_loaded(estate.id)

      conn
      |> put_status(:created)
      # |> put_resp_header("location", estate_path(conn, :show, estate_db))
      |> render("show.json", estate: estate_db)
    end
  end

  def append_images_to_estate(conn, %{"estate_id" => estate_id, "images" => images}) do
    with {:ok, images} <- Estates.append_images(estate_id, images) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", estate_path(conn, :show, estate_db))
      |> render("show_estate_images.json", estate_id: estate_id, images: images)
    end
  end

  def show(conn, %{"team_id" => _team_id, "estate_id" => estate_id}) do
    estate = Estates.get_fully_loaded(estate_id)
    render(conn, "show.json", estate: estate)
  end

  def estate_events_list(conn, %{"team_id" => _team_id, "estate_id" => estate_id}) do
    estate_events = Estates.latest_estate_events(estate_id)
    render(conn, "event_list.json", events: estate_events)
  end

  def team_events_list(conn, %{"team_id" => team_id}) do
    team_estate_events = Estates.latest_estate_changes(team_id)
    render(conn, "event_list.json", events: team_estate_events)
  end

  def update(conn, %{"team_id" => _team_id, "id" => id, "estate" => estate_params}) do
    original_estate = Estates.get_estate!(id) |> Repo.preload([:current_price])
    user = conn.assigns[:user]

    extra_params = translate_estate_extra_params(conn, estate_params)
    estate_params = Map.merge(estate_params, extra_params)

    # Update all passed
    with {:ok, %Estate{} = estate} <- Estates.update_estate(original_estate, estate_params),
         {:ok, %Estate{} = estate} <- Estates.update_price(estate, estate_params),
         {:ok, _estate_change} <-
           Estates.append_estate_update(original_estate, estate, estate_params, user.id) do
      # Get
      updated_estate =
        Estates.get_estate!(estate.id)
        |> Repo.preload([
          :current_price,
          :location,
          :main_contact,
          :estate_status,
          :estate_type,
          :images
        ])

      render(conn, "show.json", estate: updated_estate)
    end
  end

  def update_location(conn, %{"team_id" => _team_id, "id" => id, "estate" => estate_params}) do
    estate = Estates.get_estate!(id)

    user = conn.assigns[:user]

    estate_params =
      Map.merge(estate_params, %{
        "updated_by_id" => user.id
      })

    # Update all passed
    with {:ok, %Estate{} = estate} <- Estates.update_location(estate, estate_params),
         {:ok, _estate_event} <-
           Estates.append_location_change_event(estate, estate_params["location"], user.id) do
      # Get
      updated_estate =
        Estates.get_estate!(estate.id)
        |> Repo.preload([
          :current_price,
          :location,
          :main_contact,
          :estate_status,
          :estate_type,
          :images
        ])

      render(conn, "show.json", estate: updated_estate)
    end
  end

  defp translate_estate_extra_params(conn, estate_params) do
    # Add the id s the user who did the update
    user = conn.assigns[:user]
    type_name = estate_params["type"]
    type = Estates.get_estate_type_by_name(type_name)

    translate_contact_params(estate_params, %{
      "estate_type_id" => type.id,
      "updated_by_id" => user.id
    })
  end

  defp translate_contact_params(%{"main_contact" => main_contact} = _estate_params, attrs) do
    if main_contact["id"] != nil do
      attrs |> Map.put("main_contact_id", main_contact["id"])
    else
      attrs
    end
  end

  defp translate_contact_params(_estate_params, attrs) do
    attrs
  end

  def delete(conn, %{"team_id" => team_id, "id" => id}) do
    estate = Estates.get_estate!(id)
    user = conn.assigns[:user]

    {team_id, _} = Integer.parse(team_id)

    cond do
      estate.team_id == team_id ->
        with %Estate{} = _estate <- Estates.mark_as_deleted(estate, user.id),
             {:ok, _estate_event} <- Estates.append_delete_event(estate, user.id) do
          conn
          |> put_status(200)
          |> json(%{success: true})
        end

      true ->
        conn
        |> put_status(401)
        |> json(%{success: false, message: "Forbidden"})
    end
  end

  def assignment(conn, %{"id" => estate_id} = params) do
    user = conn.assigns[:user]

    # Get it here because is optional
    assign_to = params["assign_to"]

    with {:ok, updated_estate} <- Estates.assign_estate_to(estate_id, user.id, assign_to),
         {:ok, _estate_event} <- Estates.append_assign_event(updated_estate, assign_to) do
      conn
      |> render("assignment_success.json", estate: updated_estate)
    end
  end

  def change_status(conn, %{"team_id" => _team_id, "id" => estate_id, "status" => status}) do
    user = conn.assigns[:user]

    with {:ok, updated_estate} <- Estates.change_estate_status(estate_id, status, user.id),
         {:ok, _estate_event} <- Estates.append_status_event(updated_estate, status, user.id) do
      conn
      |> render("status_change_success.json", estate: updated_estate)
    else
      {:error, :invalid_status} ->
        conn
        |> put_status(400)
        |> json(%{message: "Invalid status: #{status}"})
    end
  end
end
