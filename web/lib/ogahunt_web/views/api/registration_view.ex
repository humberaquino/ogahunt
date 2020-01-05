defmodule OgahuntWeb.Api.RegistrationView do
  use OgahuntWeb, :view

  # alias __MODULE__

  def render("registration_success.json", %{registration: _registration}) do
    %{
      success: true
    }
  end

  def render("registration_failure.json", %{changeset: _changeset}) do
    %{
      success: false,
      error: "Can't create registration"
    }
  end

  def render("team_user_invitations.json", %{invitations: invitations}) do
    %{
      invitations: Enum.map(invitations, fn invitation -> render_invitation(invitation) end)
    }
  end

  def render_invitation(invitation) do
    %{
      id: invitation.id,
      email: invitation.email,
      invite_expires_at: invitation.invite_expires_at,
      invite_accepted: invitation.invite_accepted,
      invite_accepted_at: invitation.invite_accepted_at,
      team_id: invitation.team_id,
      inviter_id: invitation.inviter_id,
      user_id: invitation.user_id,
      inserted_at: invitation.inserted_at
    }
  end

  # def render("complete_registration_success.json", %{registration: _registration}) do
  #   %{
  #     success: true
  #   }
  # end

  # def render("complete_registration_error.json", %{params: _params, error: _error}) do
  #   %{
  #     success: false,
  #     error: "Unexpected registration error"
  #   }
  # end

  # def render("complete_registration_validation_failure.json", %{params: _params}) do
  #   %{
  #     success: false,
  #     error: "Validation failed"
  #   }
  # end
end
