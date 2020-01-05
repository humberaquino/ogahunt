defmodule Ogahunt.Estates.EstateStatus do
  use Ecto.Schema

  # ["open", "archived", "trash"]
  @estate_status_map %{
    :open => "open",
    :archived => "archived"
  }

  def estate_status_map, do: @estate_status_map
  def estate_status_values, do: Enum.map(estate_status_map(), fn {_k, v} -> v end)

  def estate_status_value_open(), do: @estate_status_map[:open]
  def estate_status_value_archived(), do: @estate_status_map[:archived]

  schema "estate_status" do
    field(:name, :string)
  end
end
