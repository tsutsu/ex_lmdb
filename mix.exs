defmodule ExLMDB.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_lmdb,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elmdb, "~> 0.4.1"}
    ]
  end
end
