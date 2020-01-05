defmodule Ogahunt.Accounts.TeamStatus do
  use Ecto.Schema

  @team_status_map %{
    :active => "active",
    :inactive => "inactive",
    :archived => "archived"
  }

  def team_status_map, do: @team_status_map
  def team_status_values, do: Enum.map(team_status_map(), fn {_k, v} -> v end)

  def team_status_value_active(), do: @team_status_map[:active]
  def team_status_value_inactive(), do: @team_status_map[:inactive]
  def team_status_value_archived(), do: @team_status_map[:archived]

  schema "team_status" do
    field(:name, :string)
  end
end
