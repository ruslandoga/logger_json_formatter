defmodule LoggerJSONFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :logger_json_formatter,
      version: "0.1.0",
      elixir: "~> 1.15",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"}
    ]
  end
end
