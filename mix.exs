defmodule ExLMDB.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ex_lmdb,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExLMDB",
      description: "Elixir wrapper for the LMDB embedded key-value store",
      source_url: "https://github.com/tsutsu/ex_lmdb",
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Levi Aul"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tsutsu/ex_lmdb"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "ExLMDB.Database"
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :docs},
      {:elmdb, "~> 0.4.1"}
    ]
  end
end
