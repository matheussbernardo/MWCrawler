defmodule MWCrawler.Crawler do
  def course(code) do
    curriculum_body = get_curriculum_body(code)
    course_name = get_course_name(curriculum_body)
    required_credits = get_required_credits(curriculum_body)
    curriculum = get_curriculum(curriculum_body)

    course = %{name: course_name, credits: required_credits, curriculum: curriculum}
    Poison.encode!(course)
  end

  defp get_curriculum_body(code) do
    url = "https://matriculaweb.unb.br/graduacao/curso_dados.aspx?cod=#{code}"
    course_body = HTTPoison.get!(url).body

    option_code =
      course_body |> Floki.find(".table-responsive h4 small") |> Floki.text() |> String.trim()

    url = "https://matriculaweb.unb.br/graduacao/curriculo.aspx?cod=#{option_code}"
    HTTPoison.get!(url).body
  end

  defp get_course_name(body) do
    [{_, _, [name, _]}] = Floki.find(body, ".header h2")
    name |> String.trim_leading()
  end

  defp get_required_credits(body) do
    [{_, _, [_, {_, _, [credits]}, _]}] =
      body
      |> Floki.find("#datatable tr:nth-child(9)")

    credits
  end

  defp get_curriculum(body) do
    raw_list_of_courses =
      body
      |> Floki.find("div.body.table-responsive table a")

    Enum.map(raw_list_of_courses, fn {_, [{_, href}], [title]} ->
      %{
        code: href |> String.slice(-6..String.length(href)),
        title: title |> String.trim_leading()
      }
    end)
  end

  defp course_dependencies(body) do
    stream = Task.async_stream(links_of_courses(body), fn link -> get_dependency(link) end)
    Enum.map(stream, fn {:ok, content} -> content end)
  end

  defp links_of_courses(body) do
    body |> Floki.find("div.body.table-responsive table a") |> Floki.attribute("href")
  end

  defp get_dependency(url) do
    body = HTTPoison.get!("https://matriculaweb.unb.br/#{url}").body
    body |> Floki.find("#datatable tr:nth-child(6) a") |> Floki.text()
  end
end
