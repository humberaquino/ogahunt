defmodule Ogahunt.Estates.EstatePrice do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ogahunt.Estates.Estate
  alias Ogahunt.Estates.Currency

  schema "estate_prices" do
    field(:amount, :decimal)
    field(:notes, :string)

    belongs_to(:currency, Currency)
    belongs_to(:estate, Estate)

    timestamps(updated_at: false)
  end

  def changeset(estate_price, attrs) do
    estate_price
    |> cast(attrs, [:amount, :currency_id, :estate_id, :notes])
    |> validate_required([:amount, :currency_id, :estate_id])
  end
end
