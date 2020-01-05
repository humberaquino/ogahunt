defmodule OgahuntWeb.Api.SettingsController do
  use OgahuntWeb, :controller

  alias Ogahunt.Settings.Settings

  def global_settings(conn, _params) do
    global_settings = Settings.fetch_global()

    render(conn, "global_settings.json", global_settings: global_settings)
  end
end
