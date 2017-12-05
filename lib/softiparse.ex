defmodule Parser do
  @moduledoc """
  Documentation for Parser.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Parser.hello
      :world

  """
  def hello do
    url = "https://matriculaweb.unb.br/graduacao/fluxo.aspx?cod=6360"
    body = HTTPoison.get!(url).body

    raw_list_of_courses = body |> Floki.find("div.body.table-responsive table a") |> Floki.text(sep: "-") |> String.split("-")
    list_of_courses = Enum.map(raw_list_of_courses, fn(course) -> String.trim_trailing(course) end)
    
  end
end
