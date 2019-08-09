defmodule Unleash.MixProject do
  @moduledoc false
  use Mix.Project

  @gitlab_url "https://www.gitlab.com/afontaine/unleash_ex"

  def project do
    [
      app: :unleash,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "Unleash",
      description: "An Unleash Feature Flag client for Elixir",
      source_url: @gitlab_url,
      homepage_url: @gitlab_url,
      docs: docs(),
      files: ~w(mix.exs lib LICENSE README.md CHANGELOG.md),
      package: [
        maintainers: ["Andrew Fontaine"],
        licenses: ["MIT"],
        links: %{
          "GitLab" => @gitlab_url
        }
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Unleash, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:eliver, "~> 2.0", only: [:dev], runtime: false},
      {:stream_data, "~> 0.4.3", only: :test},
      {:excoveralls, "~> 0.8", only: :test},
      {:murmur, "~> 1.0"},
      {:tesla, "~> 1.2"},
      {:hackney, "~> 1.14"},
      {:jason, "~> 1.1"}
    ]
  end

  defp aliases do
    [
      test: ["test --no-start"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      deps: [
        tesla: "https://hexdocs.pm/tesla",
        murmur: "https://hexdocs.pm/murmur/readme.html"
      ],
      groups_for_modules: [
        Strategies: ~r"Strateg(y|ies)\."
      ]
    ]
  end
end
