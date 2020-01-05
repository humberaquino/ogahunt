defmodule OgahuntWeb.Api.UploadView do
  use OgahuntWeb, :view

  def render("success_signing.json", %{
        signed_url: signed_url,
        expires: expires,
        resource_name: resource_name
      }) do
    %{
      signed_url: signed_url,
      expires: expires,
      resource_name: resource_name
    }
  end

  def render("success_image_saved.json", %{image: _image}) do
    %{
      success: true
    }
  end
end
