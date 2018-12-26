defmodule MWParser.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mwparser,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MWParser, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.6"},
      {:plug, "~> 1.7"},
      {:plug_cowboy, "~> 2.0.1"},
      {:httpoison, "~> 1.5"},
      {:floki, "~> 0.20.4"},
      {:poison, "~> 4.0.1"}
    ]
  end
end
