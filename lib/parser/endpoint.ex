defmodule Parser.Endpoint do
  use Plug.Router

  require Logger

  plug Plug.Logger
  # NOTE: The line below is only necessary if you care about parsing JSON
  plug Plug.Parsers, parsers: [:json], json_decoder: Poison
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    port = Application.fetch_env!(:softiparse, :port)
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
  end

  get "/cursos_com_prerequisitos" do
    send_resp(conn |> put_resp_content_type("text/plain"), 200, Parser.Worker.lookup(:worker))
  end

end