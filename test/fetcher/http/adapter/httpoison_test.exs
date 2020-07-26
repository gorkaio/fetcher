defmodule Fetcher.Http.Adapter.HttpoisonTest do
  @moduledoc false
  use ExUnit.Case, async: true
  doctest Fetcher
  alias Fetcher.SiteData
  alias Plug.Conn.Query

  @base_url "http://localhost:8081/"
  @test_url @base_url <> "test"
  @redirect_url @base_url <> "redirect"
  @failure_url @base_url <> "failure"

  test "Returns empty lists for pages without links or images" do
    links = []
    assets = []
    params = %{links: links, assets: assets}

    url =
      @test_url
      |> URI.parse()
      |> Map.put(:query, Query.encode(params))
      |> URI.to_string()

    expected = {:ok, SiteData.new()}
    actual = Fetcher.fetch(url)

    assert expected == actual
  end

  test "Returns lists of assets and links" do
    links = ["https://gorka.io", "https://gorka.io/about"]
    assets = ["https://gorka.io/logo.svg", "https://gorka.io/logo2.png"]
    params = %{links: links, assets: assets}

    url =
      @test_url
      |> URI.parse()
      |> Map.put(:query, Query.encode(params))
      |> URI.to_string()

    expected = {:ok, SiteData.new() |> SiteData.with_links(links) |> SiteData.with_assets(assets)}
    actual = Fetcher.fetch(url)

    assert expected == actual
  end

  test "Follows redirects" do
    links = ["https://gorka.io", "https://gorka.io/about"]
    assets = ["https://gorka.io/logo.svg", "https://gorka.io/logo2.png"]
    params = %{links: links, assets: assets}

    redirect_to =
      @test_url
      |> URI.parse()
      |> Map.put(:query, Query.encode(params))
      |> URI.to_string()

    url =
      @redirect_url
      |> URI.parse()
      |> Map.put(:query, Query.encode(%{page: redirect_to}))
      |> URI.to_string()

    expected = {:ok, SiteData.new() |> SiteData.with_links(links) |> SiteData.with_assets(assets)}
    actual = Fetcher.fetch(url)

    assert expected == actual
  end

  test "Returns error for failed requests" do
    expected = {:error, 404}

    url =
      @failure_url
      |> URI.parse()
      |> Map.put(:query, Query.encode(%{status: 404}))
      |> URI.to_string()

    actual = Fetcher.fetch(url)

    assert expected == actual
  end
end
