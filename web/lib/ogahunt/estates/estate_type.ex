defmodule Ogahunt.Estates.EstateType do
  use Ecto.Schema

  # "house", "land", "department", "duplex", "unknown"
  @estate_type_map %{
    :house => "house",
    :land => "land",
    :department => "department",
    :duplex => "duplex",
    :unknown => "unknown"
  }

  def estate_type_map, do: @estate_type_map
  def estate_type_values, do: Enum.map(estate_type_map(), fn {_k, v} -> v end)

  def estate_type_value_house(), do: @estate_type_map[:house]
  def estate_type_value_land(), do: @estate_type_map[:land]
  def estate_type_value_department(), do: @estate_type_map[:department]
  def estate_type_value_duplex(), do: @estate_type_map[:duplex]
  def estate_type_value_unknown(), do: @estate_type_map[:unknown]

  schema "estate_types" do
    field(:name, :string)
  end
end
