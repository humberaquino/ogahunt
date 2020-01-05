defmodule OgahuntWeb.Api.ContactController do
  use OgahuntWeb, :controller

  alias Ogahunt.Contacts
  alias Ogahunt.Contacts.Contact

  action_fallback(OgahuntWeb.FallbackController)

  def team_contact_list(conn, %{"team_id" => team_id} = _params) do
    team_contacts = Contacts.list_team_contacts(team_id)
    render(conn, "index.json", contacts: team_contacts)
  end

  def create(conn, %{"team_id" => team_id, "contact" => contact_params}) do
    contact_params = Map.put(contact_params, "team_id", team_id)

    with {:ok, %Contact{} = contact} <- Contacts.create_contact(contact_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", contact_path(conn, :show, contact))
      |> render("show.json", contact: contact)
    end
  end

  def update(conn, %{"team_id" => team_id, "id" => id, "contact" => contact_params}) do
    original_contact = Contacts.get_contact!(id)
    user = conn.assigns[:user]

    contact_params =
      Map.merge(contact_params, %{"updated_by_id" => user.id, "team_id" => team_id})

    # Update all passed
    with {:ok, %Contact{} = contact} <- Contacts.update_contact(original_contact, contact_params) do
      render(conn, "show.json", contact: contact)
    end
  end

  def delete(conn, %{"team_id" => team_id, "id" => id}) do
    contact = Contacts.get_contact!(id)
    user = conn.assigns[:user]

    {team_id, _} = Integer.parse(team_id)

    cond do
      contact.team_id == team_id ->
        case Contacts.mark_as_deleted(contact, user.id) do
          {:ok, _contact} ->
            conn
            |> put_status(200)
            |> json(%{success: true})

          {:error, reason} ->
            conn
            |> put_status(200)
            |> json(%{success: false, reason: reason})
        end

      true ->
        conn
        |> put_status(401)
        |> json(%{success: false, message: "Forbidden"})
    end
  end
end
