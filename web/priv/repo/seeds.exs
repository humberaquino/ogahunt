# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ogahunt.Repo.insert!(%Ogahunt.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Ogahunt.Repo
import Ecto.Query
alias Ogahunt.Accounts.TeamStatus
alias Ogahunt.Accounts.UserStatus
alias Ogahunt.Accounts.Role

alias Ogahunt.Estates.Currency
alias Ogahunt.Estates.EstateStatus
alias Ogahunt.Estates.EstateType

# Check to see if seeds was already executed or not. Fail if it was
case from(us in UserStatus)
     |> Repo.all() do
  status when status != [] ->
    raise "Seeds already in place"

  _ ->
    IO.puts("First time seeding")
    false
end

# User status
user_status = UserStatus.user_status_values()

Enum.each(user_status, fn name ->
  Ogahunt.Repo.insert!(%UserStatus{name: name})
end)

# Team status
team_status = TeamStatus.team_status_values()

Enum.each(team_status, fn name ->
  Ogahunt.Repo.insert!(%TeamStatus{name: name})
end)

# Team roles
roles = Role.role_values()

Enum.each(roles, fn name ->
  Ogahunt.Repo.insert!(%Role{name: name})
end)

# Currencies
currencies = [{"USD", "US Dollar"}, {"PYG", "Paraguayan Guarani"}]

Enum.each(currencies, fn {code, name} ->
  Ogahunt.Repo.insert!(%Currency{code: code, name: name})
end)

# Estate status
estate_status = EstateStatus.estate_status_values()

Enum.each(estate_status, fn name ->
  Ogahunt.Repo.insert!(%EstateStatus{name: name})
end)

# EstateTypes
estate_types = EstateType.estate_type_values()

Enum.each(estate_types, fn name ->
  Ogahunt.Repo.insert!(%EstateType{name: name})
end)
