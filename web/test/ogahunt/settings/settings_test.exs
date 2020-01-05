defmodule Ogahunt.SettingsTest do
  use Ogahunt.DataCase

  alias Ogahunt.Settings.Settings

  test "fetch_global/1 gets all general config to be used by the app" do
    global_config = Settings.fetch_global()

    assert !is_nil(global_config)

    assert Enum.count(global_config.roles) == 4
    assert Enum.count(global_config.user_statuses) == 4
    assert Enum.count(global_config.estate_types) == 5
    assert Enum.count(global_config.estate_statuses) == 2
    assert Enum.count(global_config.currencies) == 2
  end
end
