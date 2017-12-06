defmodule Parser do
  defp list_of_courses do
    url = "https://matriculaweb.unb.br/graduacao/fluxo.aspx?cod=6360"
    body = HTTPoison.get!(url).body

    raw_list_of_courses = body 
                          |> Floki.find("div.body.table-responsive table a") 
                          |> Floki.text(sep: "-") 
                          |> String.split("-")
    Enum.map(raw_list_of_courses, fn(course) -> String.trim_trailing(course) |> String.to_atom  end)

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

  def courses_and_dependencies do
    courses = Enum.zip(list_of_courses(), dependencies_links())
  end
end
