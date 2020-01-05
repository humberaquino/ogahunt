defmodule OgahuntWeb.Router do
  use OgahuntWeb, :router

  # Sentry
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :logger do
    # TIMBER
    # plug(Timber.Integrations.EventPlug)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(OgahuntWeb.VerifyApiKey)
  end

  pipeline :open_api do
    plug(:accepts, ["json"])
  end

  # Internal check endpoints
  scope "/__check", OgahuntWeb do
    pipe_through(:open_api)

    get("/live", Api.HealthController, :live)
    get("/ready", Api.HealthController, :ready)
    get("/crash", Api.HealthController, :crash)
  end

  scope "/", OgahuntWeb do
    pipe_through([:browser])

    # Login
    get("/", PageController, :index)

    # complete shows html
    get("/registration/complete", Api.RegistrationController, :complete_registration)

    # Validates team_id, token and email
    # Doesn't exits: Show a form to fill the name and password. The form submits a POST to /invitation/complete
    # User exists: complete link
    get("/invitation/registration", Api.RegistrationController, :invitation_check)

    # Get the data to complete the registration of the user to this organization
    # Create the user using the data provided
    post("/invitation/complete", Api.RegistrationController, :accept_invitation)
  end

  scope "/", OgahuntWeb do
    pipe_through([:browser, OgahuntWeb.Plugs.Auth])
  end

  # Open endpoints. Both are rate limited
  scope "/api", OgahuntWeb do
    pipe_through([:logger, :open_api])

    # post("/signup", Api.AuthController, :signup)
    post("/signin", Api.AuthController, :signin)

    # Registration need to be open
    post("/register", Api.RegistrationController, :register)
  end

  # API Token endpoins
  scope "/api", OgahuntWeb do
    pipe_through([:logger, :api])

    # Settings
    get("/settings", Api.SettingsController, :global_settings)

    # Generic
    get("/users/:id", Api.UserController, :show)
    get("/users/:id/teams", Api.UserController, :user_teams)

    # Users
    ## This EP invites a user to the team
    post("/team/:team_id/users/invite", Api.UserController, :invite_user_to_team)

    post("/team/:team_id/users/add", Api.UserController, :add_user_to_team)
    get("/team/:team_id/users", Api.UserController, :team_users_list)
    get("/team/:team_id/users/invitations", Api.RegistrationController, :team_user_invitations)

    # Contacts
    get("/team/:team_id/contacts", Api.ContactController, :team_contact_list)
    post("/team/:team_id/contacts", Api.ContactController, :create)
    post("/team/:team_id/contacts/:id", Api.ContactController, :update)
    delete("/team/:team_id/contacts/:id", Api.ContactController, :delete)

    #### Estates
    ############
    post("/team/:team_id/estate", Api.EstateController, :create)
    get("/team/:team_id/estate/:estate_id", Api.EstateController, :show)
    get("/team/:team_id/estate", Api.EstateController, :index)
    post("/team/:team_id/estate/:id", Api.EstateController, :update)
    get("/team/:team_id/estate/:estate_id/events", Api.EstateController, :estate_events_list)
    get("/team/:team_id/events", Api.EstateController, :team_events_list)

    ## Partial update
    post("/team/:team_id/estate/:id/location", Api.EstateController, :update_location)

    ## Assign/unassign
    post("/team/:team_id/estate/:id/assign", Api.EstateController, :assignment)
    post("/team/:team_id/estate/:id/status", Api.EstateController, :change_status)

    delete("/team/:team_id/estate/:id", Api.EstateController, :delete)

    # Estate iamge
    post(
      "/team/:team_id/estate/:estate_id/images",
      Api.EstateController,
      :append_images_to_estate
    )

    # Upload
    get("/image/upload/req_signed_url", Api.UploadController, :req_signed_upload_url)
    get("/image/download/req_signed_url", Api.UploadController, :req_signed_download_url)
    post("/image/save_uploaded", Api.UploadController, :save_uploaded_image)
    get("/image/download/:resource_name", Api.UploadController, :download_image_indirectly)

    # resources("/estates", Api.EstateController, except: [:new, :edit])
  end
end
