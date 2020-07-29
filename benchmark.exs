url = "https://adrien.harnay.me/links/"

Benchee.run(%{
  "url_fecther" => fn -> UrlFetcher.fetch(url) end
})
