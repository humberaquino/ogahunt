defmodule Ogahunt.InternalNotificationEmail do
  @moduledoc """
  Internal Email sending module
  """

  import Bamboo.Email

  def send_registration_email(registration) do
    base_url = Ogahunt.Application.app_base_url()

    now = DateTime.utc_now() |> DateTime.to_string()
    email = registration.email
    id = registration.id
    name = registration.name

    new_email()
    |> to(admin_email())
    |> from(from_addr())
    |> subject("[Internal] 👋 #{email} registered!")
    |> html_body("<div>ID: #{id}</div>
      <div>Name: #{name}</div>
      <div>Email: #{email}</div>
      <div>App: #{base_url}</div>
      <div>Created at: #{now}</div>")
    |> text_body("ID: #{id}. Email: #{email}")
    |> Ogahunt.Mailer.deliver_later()
  end

  def send_complete_registration_email(registration) do
    base_url = Ogahunt.Application.app_base_url()

    now = DateTime.utc_now() |> DateTime.to_string()
    email = registration.email
    id = registration.id
    name = registration.name
    user_id = registration.created_by_id

    new_email()
    |> to(admin_email())
    |> from(from_addr())
    |> subject("[Internal] 🎉 Registration completed for #{email}")
    |> html_body("<div>ID: #{id}</div>
      <div>Name: #{name}</div>
      <div>Email: #{email}</div>
      <div>User Id: #{user_id}</div>

      <div>App: #{base_url}</div>
      <div>Created at: #{now}</div>")
    |> text_body("ID: #{id}. Email: #{email}")
    |> Ogahunt.Mailer.deliver_later()
  end

  def from_addr do
    Application.get_env(:ogahunt, __MODULE__) |> Keyword.get(:from_addr)
  end

  def admin_email do
    Application.get_env(:ogahunt, __MODULE__) |> Keyword.get(:admin_email)
  end
end
