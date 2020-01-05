defmodule OgahuntWeb.Plug.RateLimit do
  import Plug.Conn

  require Logger

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    prefix = opts[:prefix]
    limit_secs = opts[:limit_secs]
    limit_count = opts[:limit_count]

    ip = get_real_ip(conn)
    rate_key = "#{prefix}:#{ip}"

    case Hammer.check_rate(rate_key, limit_secs, limit_count) do
      {:allow, _count} ->
        conn

      {:deny, count} ->
        Logger.debug(fn -> "Rate limit for #{rate_key}. Count: #{count}" end)
        handle_too_many_requests(conn)
    end
  end

  defp get_real_ip(conn) do
    get_req_header(conn, "x-forwarded-for")
  end

  defp handle_too_many_requests(conn) do
    conn
    |> send_resp(429, "Too many requests")
    |> halt()
  end
end
