defmodule Ogahunt.Repo.Migrations.CreateEstatePrices do
  use Ecto.Migration

  def change do
    create table(:estate_prices) do
      add(:amount, :decimal, precision: 20, scale: 2)
      add(:currency_id, references(:currencies))

      add(:notes, :string)

      # Price belongs to a estate
      add(:estate_id, references(:estates))

      timestamps(updated_at: false)
    end

    alter table(:estates) do
      # Current pricing pointer
      add(:current_price_id, references(:estate_prices))
    end
  end
end
