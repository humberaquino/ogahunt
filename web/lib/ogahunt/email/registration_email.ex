defmodule Ogahunt.RegistrationEmail do
  @moduledoc """
  Email sending module
  """

  import Bamboo.Email

  def send_token_email(to_email, token) do
    base_url = Ogahunt.Application.app_base_url()

    encoded_query = URI.encode_query(%{email: to_email, token: token})
    registration_link = "#{base_url}/registration/complete?#{encoded_query}"

    new_email()
    |> to(to_email)
    |> from(from_addr())
    |> subject("Welcome to OgaHunt!")
    |> html_body(
      "<strong>Thanks for joining!</strong>
      Please click on <a href=\"#{registration_link}\">this link</a> to complete your registration."
    )
    |> text_body("Thanks for joining!
      Please visit the following link to complete the registration: #{registration_link}")
    |> Ogahunt.Mailer.deliver_later()
  end

  def send_invitation_token_email(inviter, team_id, to_email, token) do
    base_url = Ogahunt.Application.app_base_url()

    encoded_query = URI.encode_query(%{team_id: team_id, email: to_email, token: token})
    registration_link = "#{base_url}/invitation/registration?#{encoded_query}"

    new_email()
    |> to(to_email)
    |> from(from_addr())
    |> subject("You have been invited to OgaHunt!")
    |> html_body(
      "Hi there! <strong>#{inviter}</strong> invited you to join his Ogahunt team!
      If you want to accept this invitation please click <a href=\"#{registration_link}\">this link</a> and complete the form."
    )
    |> text_body("Hi there! #{inviter} invited you to join his Ogahunt team.
    If you want to accept this invitation please click the follwing link: #{registration_link}")
    |> Ogahunt.Mailer.deliver_later()
  end

  def from_addr do
    Application.get_env(:ogahunt, __MODULE__) |> Keyword.get(:from_addr)
  end
end
