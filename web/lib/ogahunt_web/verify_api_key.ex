defmodule OgahuntWeb.VerifyApiKey do
  @moduledoc """
  Verifies the API key
  """
  import Plug.Conn, only: [halt: 1, put_status: 2, assign: 3]
  import Phoenix.Controller, only: [render: 3, json: 2, put_view: 2]

  alias Ogahunt.Auth
  alias Ogahunt.AuthPolicy

  def init(opts), do: opts

  def call(conn, _opts) do
    case is_valid_api_key?(conn) do
      {true, user} ->
        # Add context to the logging
        # TIMBER
        # %Timber.Contexts.UserContext{id: user.id, name: user.name, email: user.email}
        # |> Timber.add_context()

        conn
        |> assign(:user, user)
        |> handle_conn(true)

      {false, _reason} ->
        conn
        |> handle_conn(false)

      error ->
        conn
        |> handle_conn(error)
    end
  end

  def handle_conn(conn, true) do
    user = conn.assigns[:user]

    # Estract team_id from the params
    case conn.path_params do
      %{"team_id" => team_id} ->
        with :ok <- Bodyguard.permit(AuthPolicy, :teamwide_access, user, team_id) do
          # Allow
          conn
        else
          _ ->
            forbidden_access(conn, "Forbidden")
        end

      _ ->
        # Not team related. Allow
        conn
    end
  end

  def handle_conn(conn, false), do: invalid_api_key(conn, "Invalid API key")

  def handle_conn(conn, {:error, :missing_auth_header}) do
    invalid_api_key(conn, "Missing API key")
  end

  def handle_conn(conn, {:error, _error}), do: invalid_api_key(conn, "Unknown key error")

  def handle_conn(conn, msg) do
    invalid_api_key(conn, msg)
  end

  def is_valid_api_key?(conn) do
    with {:ok, header} <- fetch_auth_header(conn),
         {:ok, decoded_header} <- decode_auth_header(header),
         {:ok, email, api_key} = extract_user_and_api_key(decoded_header) do
      Auth.verify_api_key(email, api_key)
    else
      error ->
        error
    end
  end

  def extract_user_and_api_key(decoded_header) do
    case String.split(decoded_header, ":") do
      [email, api_key] ->
        {:ok, email, api_key}

      _ ->
        {:error, "Malformed API key content"}
    end
  end

  def invalid_api_key(conn, reason) do
    conn
    |> put_status(401)
    |> put_view(OgahuntWeb.ErrorView)
    |> render("invalid_api_key.json", reason: reason)
    |> halt()
  end

  def forbidden_access(conn, reason) do
    conn
    |> put_status(403)
    |> json(%{"reason" => reason})
    |> halt()
  end

  def fetch_auth_header(conn) do
    with {:ok, value} <-
           conn.req_headers
           |> Enum.into(%{})
           |> Map.fetch("authorization") do
      {:ok, value}
    else
      :error ->
        {:error, :missing_auth_header}
    end
  end

  def decode_auth_header(auth_header) do
    case String.split(auth_header, " ") do
      [type, key] ->
        case String.downcase(type) do
          "basic" ->
            case Base.decode64(key) do
              {:ok, res} ->
                {:ok, res}

              _ ->
                {:error, "Invalid Authorization Header Format: Not base64"}
            end

          _ ->
            {:error, "Unsupported Authorization Header Format: Type is not Basic"}
        end

      _ ->
        {:error, "Invalid Authorization Header Format: Type and key not provided"}
    end
  end
end
