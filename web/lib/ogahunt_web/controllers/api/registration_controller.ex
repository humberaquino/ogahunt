defmodule OgahuntWeb.Api.RegistrationController do
  use OgahuntWeb, :controller

  require Logger

  alias Ogahunt.Registrations.Registrations
  alias Ogahunt.RegistrationEmail
  alias Ogahunt.InternalNotificationEmail
  alias Ogahunt.Accounts
  alias Ogahunt.Accounts.Role

  action_fallback(OgahuntWeb.Api.ErrorController)

  @rate_limit_register_secs 60_000
  @rate_limit_register_count 5
  @rate_limit_complete_secs 30_000
  @rate_limit_complete_count 3

  plug(
    OgahuntWeb.Plug.RateLimit,
    %{
      prefix: "register",
      limit_secs: @rate_limit_register_secs,
      limit_count: @rate_limit_register_count
    }
    when action in [:register]
  )

  plug(
    OgahuntWeb.Plug.RateLimit,
    %{
      prefix: "complete_registration",
      limit_secs: @rate_limit_complete_secs,
      limit_count: @rate_limit_complete_count
    }
    when action in [:complete_registration]
  )

  def register(conn, %{"email" => email} = params) do
    with {:ok, _valid} <- validate_registration_args(params),
         {:ok, _can_reg} <- Registrations.can_register(params),
         {:ok, registration} <- Registrations.create_registration(params) do
      RegistrationEmail.send_token_email(registration.email, registration.token)
      InternalNotificationEmail.send_registration_email(registration)

      render(conn, "registration_success.json", registration: registration)
    else
      {:error, :already_registered} ->
        conn
        |> json(%{success: false, message: "User already registered: #{email}"})

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render("registration_failure.json", changeset: changeset)
    end
  end

  defp validate_registration_args(params) do
    required_keys = ["name", "email", "password", "password_confirmation"]

    case Enum.all?(required_keys, fn key -> params[key] != nil end) do
      true ->
        {:ok, true}

      _ ->
        {:error, :missing}
    end
  end

  def complete_registration(conn, %{"email" => _email, "token" => _token} = params) do
    # Validate
    case Registrations.validate_registration(params) do
      nil ->
        render(conn, "complete_registration_validation_failure.html", params: params)

      registration ->
        # Complete the process
        with {:ok, completed_registration} <- Registrations.complete_registration(registration) do
          InternalNotificationEmail.send_complete_registration_email(completed_registration)

          render(conn, "complete_registration_success.html", registration: completed_registration)
        else
          error ->
            conn
            |> put_status(500)
            |> render("complete_registration_error.html", params: params, error: error)
        end
    end
  end

  def invitation_check(conn, %{"team_id" => team_id, "token" => token, "email" => email} = params) do
    # Check is valid
    case Registrations.validate_invitation(team_id, email, token) do
      nil ->
        Logger.warn("Invalid invitation check for #{email} (Team #{team_id}). Token: #{token}")
        render(conn, "invalid_invitation.html", params: params)

      invitation ->
        case Accounts.get_user_by_email(invitation.email) do
          nil ->
            render(
              conn,
              "complete_user_registration_form.html",
              team_id: team_id,
              email: email,
              token: token
            )

          user ->
            complete_invitation_setup(conn, invitation, user)
        end
    end
  end

  defp complete_invitation_setup(conn, invitation, user) do
    user_role = Accounts.get_role_by_name(Role.role_value_user())

    with {:ok, _invitation} <-
           Registrations.complete_accept_invitation_with_user(invitation, user, user_role.id) do
      render(conn, "invitation_setup_complete.html")
      # else
      #   {:error, error} ->
      #     render(conn, "error_completing_invitation_setup.html", error: error)
    end
  end

  def accept_invitation(conn, params) do
    # get invitation
    with {:ok, true} <- accept_validation_valid_password(params),
         {:ok, true} <- accept_validation_valid_name(params) do
      complete_accept_invitation(conn, params)
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, "Invalid values: #{reason}")
        |> redirect(to: Routes.registration_path(conn, :invitation_check, params))
    end
  end

  defp accept_validation_valid_password(
         %{"password" => password, "password_confirmation" => password_confirmation} = _params
       ) do
    case password == password_confirmation do
      true ->
        {:ok, true}

      _ ->
        {:error, "Non matching passwords"}
    end
  end

  defp accept_validation_valid_name(%{"name" => name} = _params) do
    case String.length(name) > 0 do
      true ->
        {:ok, true}

      _ ->
        {:error, "Empty name"}
    end
  end

  defp complete_accept_invitation(
         conn,
         %{"team_id" => team_id, "email" => email, "token" => token} = params
       ) do
    case Registrations.validate_invitation(team_id, email, token) do
      nil ->
        Logger.warn("Invalid invitation for #{email} (Team #{team_id}). Token: #{token}")
        render(conn, "invalid_invitation.html", params: params)

      invitation ->
        with {:ok, _invitation} <- Registrations.complete_accept_invitation(invitation, params) do
          render(conn, "invitation_setup_complete.html")
        end
    end
  end

  def team_user_invitations(conn, %{"team_id" => team_id} = _params) do
    # Get a list of invitations
    invitations = Registrations.team_user_invitations(team_id)
    # Render
    render(conn, "team_user_invitations.json", invitations: invitations)
  end
end
