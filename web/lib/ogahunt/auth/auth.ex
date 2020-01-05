defmodule Ogahunt.Auth do
  @moduledoc """
  Module related to all the things authentication and open methods.
  Extra care should be taken because the input could be from non authorized sources. E.g. signup
  """

  alias Ogahunt.Repo
  alias Ogahunt.Accounts.User
  alias Ogahunt.Accounts

  def auth_user(email, password) do
    with user <- Accounts.get_user_by_email(email),
         {:ok, login_user} <- login(user, password) do
      {:ok, login_user}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp login(user, password) do
    Comeonin.Bcrypt.check_pass(user, password)
  end

  def verify_api_key(email, api_key) do
    case(Repo.get_by(User, email: email, api_key: api_key)) do
      nil -> {false, :nouser}
      user -> {true, user}
    end
  end
end
