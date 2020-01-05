defmodule Ogahunt.Settings.Settings do
  import Ecto.Query, warn: false
  alias Ogahunt.Repo

  alias Ogahunt.Estates.EstateType
  alias Ogahunt.Estates.EstateStatus
  alias Ogahunt.Estates.Currency
  alias Ogahunt.Accounts.Role
  alias Ogahunt.Accounts.UserStatus

  def fetch_global() do
    # Get: estate_type, estate_status, currency, roles, user_status

    estate_types = Repo.all(EstateType)
    estate_statuses = Repo.all(EstateStatus)
    currencies = Repo.all(Currency)
    roles = Repo.all(Role)
    user_statuses = Repo.all(UserStatus)

    %{
      estate_types: estate_types,
      estate_statuses: estate_statuses,
      currencies: currencies,
      roles: roles,
      user_statuses: user_statuses
    }
  end
end
