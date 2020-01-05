defmodule OgahuntWeb.ErrorView do
  use OgahuntWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def render("400.json", _assigns) do
    %{message: "Bad request!"}
  end

  def render("404.json", _assigns) do
    %{message: "Resource not found"}
  end

  def render("500.json", _assigns) do
    %{message: "An unhandled exception has occurred"}
  end

  def render("invalid_api_key.json", %{reason: reason}) do
    %{message: reason}
  end
end
