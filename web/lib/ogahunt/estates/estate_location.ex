defmodule Ogahunt.Estates.EstateLocation do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Estates.Estate

  schema "estate_locations" do
    field(:longitude, :float)
    field(:latitude, :float)

    has_one(:estate, {"location", Estate})

    timestamps()
  end

  def changeset(%EstateLocation{} = estate_location, attrs \\ %{}) do
    estate_location
    |> cast(attrs, [:longitude, :latitude])
    |> validate_required([:longitude, :latitude])
  end
end
