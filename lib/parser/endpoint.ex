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
    port = Application.fetch_env!(:hello_webhook, :port)
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
  end

  get "/cursos_com_prerequisitos" do
    send_resp(conn, 200, courses_and_dependencies())
  end

  defp list_of_courses do
    url = "https://matriculaweb.unb.br/graduacao/curriculo.aspx?cod=6360"
    body = HTTPoison.get!(url).body

    raw_list_of_courses = body 
                          |> Floki.find("div.body.table-responsive table a") 
                          |> Floki.text(sep: "-") 
                          |> String.split("-")
    Enum.map(raw_list_of_courses, fn(course) -> String.trim_trailing(course) end)

  end

  defp links_of_courses do
    url = "https://matriculaweb.unb.br/graduacao/fluxo.aspx?cod=6360"
    body = HTTPoison.get!(url).body
    body |> Floki.find("div.body.table-responsive table a") |> Floki.attribute("href") 
  end
  
  defp get_dependency(url) do
    body = HTTPoison.get!("https://matriculaweb.unb.br/#{url}").body
    body |> Floki.find("#datatable tr:nth-child(6) a") |> Floki.text
  end
  
  defp dependencies_links do
    Task.async_stream(links_of_courses(), fn(link) -> get_dependency(link) end)
  end

  defp courses_and_dependencies do
    stream = dependencies_links()
    links = Enum.map(stream, fn({:ok, content}) -> content end )
    IO.inspect links
    courses = Enum.zip(list_of_courses(), links) |> Enum.into(%{})
    Poison.encode!(courses)
  end

end