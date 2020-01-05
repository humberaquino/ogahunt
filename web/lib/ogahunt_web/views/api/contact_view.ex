defmodule OgahuntWeb.Api.ContactView do
  use OgahuntWeb, :view
  alias __MODULE__

  def render("index.json", %{contacts: contacts}) do
    %{contacts: render_many(contacts, ContactView, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{contact: render_one(contact, ContactView, "contact.json")}
  end

  def render("contact.json", %{contact: contact}) do
    %{
      id: contact.id,
      team_id: contact.team_id,
      first_name: contact.first_name,
      last_name: contact.last_name,
      phone1: contact.phone1,
      phone2: contact.phone2,
      details: contact.details,
      version: contact.version
    }
  end
end
