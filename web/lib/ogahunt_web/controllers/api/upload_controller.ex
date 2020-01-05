defmodule OgahuntWeb.Api.UploadController do
  use OgahuntWeb, :controller

  alias Ogahunt.Estates

  def req_signed_upload_url(conn, %{"estate_id" => estate_id, "name" => name}) do
    client = Application.get_env(:ogahunt, :gcs_signer)
    bucket = Application.get_env(:ogahunt, :gcs_image_bucket)

    resource_name = "e#{estate_id}-#{name}"
    expires = GcsSigner.hours_after(2)

    signed_url =
      GcsSigner.sign_url(
        client,
        bucket,
        resource_name,
        verb: "PUT",
        content_type: "image/jpeg",
        expires: expires
      )

    render(
      conn,
      "success_signing.json",
      signed_url: signed_url,
      expires: expires,
      resource_name: resource_name
    )
  end

  def req_signed_download_url(conn, %{"resource_name" => resource_name}) do
    {:ok, signed_url, opts} = OgahuntWeb.GCSSigner.signed_url(:get, resource_name)

    render(
      conn,
      "success_signing.json",
      signed_url: signed_url,
      expires: Keyword.get(opts, :expires),
      resource_name: resource_name
    )
  end

  def save_uploaded_image(
        conn,
        %{"estate_id" => estate_id, "resource_name" => resource_name} = params
      ) do
    user = conn.assigns[:user]

    # Create an image in the DB
    image = %{"image_url" => resource_name, "is_deleted" => false}

    with estate <- Estates.get_estate!(estate_id),
         {:ok, saved_image} <- Estates.append_image(estate_id, image) do
      if params["save_event"] do
        {:ok, _estate_event} = Estates.append_image_added_event(estate, resource_name, user.id)
        render(conn, "success_image_saved.json", image: saved_image)
      else
        render(conn, "success_image_saved.json", image: saved_image)
      end
    end
  end

  def download_image_indirectly(conn, %{"resource_name" => resource_name}) do
    # TODO: Check that we have perms to check out the requested image

    # Req signed
    {:ok, signed_url, _opts} = OgahuntWeb.GCSSigner.signed_url(:get, resource_name)

    # Redirect
    redirect(conn, external: signed_url)
  end
end
