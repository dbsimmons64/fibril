defmodule Fibril.MixProject do
  use Mix.Project

  def project do
    [
      app: :fibril,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:phoenix_view, "~> 2.0"},
      {:ecto_sql, "~> 3.10"},
      {:phoenix_live_view, "~> 0.20.2"},
      {:gettext, "~> 0.20"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.2"},
      {:floki, ">= 0.30.0", only: :test}

    ]
  end
end
