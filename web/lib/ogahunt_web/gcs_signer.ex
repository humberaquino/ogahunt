defmodule OgahuntWeb.GCSSigner do
  def signed_url(verb, resource_name) do
    signed_url(verb, resource_name, 2)
  end

  def signed_url(:get, resource_name, expires_after_hours) do
    _signed_url("GET", resource_name, expires_after_hours)
  end

  def signed_url(:put, resource_name, expires_after_hours) do
    _signed_url("PUT", resource_name, expires_after_hours)
  end

  defp _signed_url(verb, resource_name, expires_after_hours) do
    expires = GcsSigner.hours_after(expires_after_hours)

    content_type = "image/jpeg"

    client = Application.get_env(:ogahunt, :gcs_signer)
    bucket = Application.get_env(:ogahunt, :gcs_image_bucket)

    signed_url =
      GcsSigner.sign_url(
        client,
        bucket,
        resource_name,
        verb: verb,
        expires: expires,
        content_type: content_type
      )

    {:ok, signed_url, expires: expires, verb: verb, content_type: content_type}
  end
end
