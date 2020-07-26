ExUnit.start()
Mox.defmock(Fetcher.HttpClientMock, for: Fetcher.Http.Client)
Application.ensure_all_started(:mox)
