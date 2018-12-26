defmodule MWCrawler.Endpoint do
  use Plug.Router

  require Logger

  plug(Plug.Logger)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:match)
  plug(:dispatch)

  def init(options) do
    options
  end

  def start_link do
    port = Application.fetch_env!(:mwcrawler, :port)
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
  end

  get "/course/:code" do
    send_resp(
      conn |> put_resp_content_type("application/json"),
      200,
      MWCrawler.Crawler.course(code)
    )
  end

  match _ do
    send_resp(conn, 404, "404 oops")
  end
end
