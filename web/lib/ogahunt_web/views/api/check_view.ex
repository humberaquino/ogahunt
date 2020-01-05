defmodule OgahuntWeb.Api.CheckView do
  use OgahuntWeb, :view

  def render("index.json", _params) do
    %{
      "success" => true,
      "version" => "1.0.1"
    }
  end
end
