defmodule Ogahunt.Accounts.Role do
  use Ecto.Schema

  @role_map %{
    :owner => "owner",
    :admin => "admin",
    :user => "user",
    :viewer => "viewer"
  }

  def role_map, do: @role_map
  def role_values, do: Enum.map(role_map(), fn {_k, v} -> v end)

  def role_value_owner(), do: @role_map[:owner]
  def role_value_admin(), do: @role_map[:admin]
  def role_value_user(), do: @role_map[:user]
  def role_value_viewer(), do: @role_map[:viewer]

  schema "roles" do
    field(:name, :string)
  end
end
