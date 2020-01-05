defmodule Ogahunt.Estates.Currency do
  use Ecto.Schema

  schema "currencies" do
    field(:name, :string)
    field(:code, :string)

    timestamps()
  end
end
