defmodule TpIasc.MixProject do
  use Mix.Project

  def project do
    [
      app: :tp_iasc,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :wx, :runtime_tools, :observer],
      mod: {TpIasc, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 2.12"},
      {:plug_cowboy, "~> 2.0"},
      {:horde, "~> 0.9.0"}
    ]
  end
end
