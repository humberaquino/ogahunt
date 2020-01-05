defmodule OgahuntWeb.Api.SettingsView do
  use OgahuntWeb, :view

  #   estate_types = Repo.all(EstateType)
  #   estate_statuses = Repo.all(EstateStatus)
  #   currencies = Repo.all(Currency)
  #   roles = Repo.all(Role)
  #   user_statuses = Repo.all(UserStatus)
  def render("global_settings.json", %{global_settings: global_settings}) do
    %{
      estate_types: render_estate_types(global_settings),
      estate_statuses: render_estate_statuses(global_settings),
      currencies: render_currencies(global_settings),
      roles: render_roles(global_settings),
      user_statuses: render_user_statuses(global_settings)
    }
  end

  defp render_estate_types(%{estate_types: estate_types}) do
    Enum.map(estate_types, &render_estate_type/1)
  end

  defp render_estate_type(estate_type) do
    %{
      id: estate_type.id,
      name: estate_type.name
    }
  end

  defp render_estate_statuses(%{estate_statuses: estate_statuses}) do
    Enum.map(estate_statuses, &render_estate_status/1)
  end

  defp render_estate_status(estate_status) do
    %{
      id: estate_status.id,
      name: estate_status.name
    }
  end

  defp render_currencies(%{currencies: currencies}) do
    Enum.map(currencies, &render_currency/1)
  end

  defp render_currency(currency) do
    %{
      id: currency.id,
      name: currency.name,
      code: currency.code
    }
  end

  defp render_roles(%{roles: roles}) do
    Enum.map(roles, &render_role/1)
  end

  defp render_role(role) do
    %{
      id: role.id,
      name: role.name
    }
  end

  defp render_user_statuses(%{user_statuses: user_statuses}) do
    Enum.map(user_statuses, &render_user_status/1)
  end

  defp render_user_status(user_status) do
    %{
      id: user_status.id,
      name: user_status.name
    }
  end
end
