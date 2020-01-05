defmodule Ogahunt.Estates.EstateEventType do
  @moduledoc """
  Represents a type of events recorded on estate_events
  """
  @estate_event_type_map %{
    :estate_created => "estate_created",
    :estate_deleted => "estate_deleted",
    :estate_assigned => "estate_assigned",
    :estate_unassigned => "estate_unassigned",
    :estate_archived => "estate_archived",
    :estate_open => "estate_open",
    :estate_location_change => "estate_location_change",
    :estate_image_added => "estate_image_added",
    :estate_details_updated => "estate_details_updated"
  }

  def estate_event_type_map, do: @estate_event_type_map
  def estate_event_type_values, do: Enum.map(estate_event_type_map(), fn {_k, v} -> v end)

  def estate_event_type_value_created(), do: @estate_event_type_map[:estate_created]
  def estate_event_type_value_deleted(), do: @estate_event_type_map[:estate_deleted]
  def estate_event_type_value_assigned(), do: @estate_event_type_map[:estate_assigned]
  def estate_event_type_value_unassigned(), do: @estate_event_type_map[:estate_unassigned]
  def estate_event_type_value_archived(), do: @estate_event_type_map[:estate_archived]
  def estate_event_type_value_open(), do: @estate_event_type_map[:estate_open]
  def estate_event_type_value_image_added(), do: @estate_event_type_map[:estate_image_added]

  def estate_event_type_value_location_change(),
    do: @estate_event_type_map[:estate_location_change]

  def estate_event_type_value_details_updated(),
    do: @estate_event_type_map[:estate_details_updated]
end
