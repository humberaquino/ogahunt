defmodule Ogahunt.Estates.EstateImage do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Ogahunt.Estates.Estate

  schema "estate_images" do
    field(:image_url, :string)
    field(:is_deleted, :boolean, default: false)

    belongs_to(:estate, Estate)

    timestamps()
  end

  def changeset(%EstateImage{} = estate_image, attrs \\ %{}) do
    estate_image
    |> cast(attrs, [:estate_id, :image_url, :is_deleted])
    |> validate_required([:estate_id, :image_url])
  end
end
