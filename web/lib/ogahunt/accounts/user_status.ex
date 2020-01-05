defmodule Ogahunt.Accounts.UserStatus do
  use Ecto.Schema

  # user_status = ["invited", "active", "inactive", "archived"]
  @user_status_map %{
    :invited => "invited",
    :active => "active",
    :inactive => "inactive",
    :archived => "archived"
  }

  def user_status_map, do: @user_status_map
  def user_status_values, do: Enum.map(user_status_map(), fn {_k, v} -> v end)

  def user_status_value_active(), do: @user_status_map[:active]
  def user_status_value_inactive(), do: @user_status_map[:inactive]
  def user_status_value_invited(), do: @user_status_map[:invited]
  def user_status_value_archived(), do: @user_status_map[:archived]

  schema "user_status" do
    field(:name, :string)
  end
end
