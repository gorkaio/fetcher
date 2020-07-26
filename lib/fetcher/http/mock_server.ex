defmodule Fetcher.Http.MockServer do
  @moduledoc """
  Mock server

  ## Routes

    - `/test` generates an html response page. Takes two query params:
      - links: list of link urls to embed in the html response body
      - assets: list of img urls to embed in the html response body
    - `/failure` generates an http error response. Takes one optional query param:
      - status: http status code to be returned
    - `/redirect` generates an http 301 redirect response. Takes one query param:
      - page: absolute url of page to be redirected to
  """
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/test" do
    conn =
      conn
      |> fetch_query_params()

    query_params = %{"assets" => [], "links" => []} |> Map.merge(conn.query_params)

    case query_params do
      %{"assets" => assets, "links" => links} -> success(conn, links, assets)
      _ -> failure(conn, :bad_request)
    end
  end

  get "/failure" do
    conn =
      conn
      |> fetch_query_params()

    case conn.query_params do
      %{"status" => status} -> failure(conn, status |> String.to_integer())
      _ -> failure(conn)
    end
  end

  get "/redirect" do
    conn =
      conn
      |> fetch_query_params()

    case conn.query_params do
      %{"page" => page} -> redirect(conn, page)
      _ -> failure(conn)
    end
  end

  defp redirect(conn, page) do
    conn
    |> Plug.Conn.put_resp_header("Location", page)
    |> Plug.Conn.send_resp(:moved_permanently, "")
    |> halt()
  end

  defp success(conn, links, assets) do
    conn
    |> Plug.Conn.send_resp(:ok, body(links, assets))
  end

  defp failure(conn, status \\ :internal_server_error) do
    conn
    |> Plug.Conn.send_resp(status, "")
  end

  defp body(links, assets) do
    links =
      Enum.map(links, fn l -> "<li><a href=\"#{l}\">link</a></li>\n" end)
      |> Enum.join()

    assets =
      Enum.map(assets, fn a -> "<img src=\"#{a}\" />\n" end)
      |> Enum.join()

    "<html><body><ul>#{links}</ul>#{assets}</body></html>"
  end
end
