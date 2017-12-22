defmodule Parser.Mixfile do
  use Mix.Project

  def project do
    [
      app: :softiparse,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger], mod: {Parser, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.3"},
      {:httpoison, "~> 0.13"},
      {:floki, "~> 0.19.0"},
      {:poison, "~> 3.1"}
    ]
  end
end
