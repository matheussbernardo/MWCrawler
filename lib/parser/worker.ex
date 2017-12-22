defmodule  Parser.Worker do
  use GenServer

  ############
  ## Client ##
  def start_link do
    json = courses_and_dependencies()
    GenServer.start_link(__MODULE__, json, name: :worker)
  end

  def lookup(server) do
    GenServer.call(server, {:lookup})
  end

  ############
  ## Server ##
  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    json = courses_and_dependencies()
    schedule_work() # Reschedule once more
    {:noreply, json}
  end

  def handle_call({:lookup}, _from, state) do
    {:reply, state, state}
  end


  defp schedule_work() do
    Process.send_after(self(), :work,  24 * 60 * 60 * 1000) # In 24 Hours
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
    url = "https://matriculaweb.unb.br/graduacao/curriculo.aspx?cod=6360"
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
    courses = Enum.zip(list_of_courses(), links) |> Enum.into(%{})
    Poison.encode!(courses)
  end
end