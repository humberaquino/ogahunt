defmodule Ogahunt.AuthPolicy do
  @moduledoc """
    Authorization policy
  """
  @behaviour Bodyguard.Policy

  alias Ogahunt.Accounts

  def authorize(:teamwide_access, user, team_id) do
    email = user.email
    Accounts.user_belongs_team(email, team_id)
  end

  def authorize(:list_estates, user, team_id) do
    email = user.email

    Accounts.user_belongs_team(email, team_id)
  end
end
