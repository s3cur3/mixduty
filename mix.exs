defmodule Mixduty.MixProject do
  use Mix.Project

  def project do
    [
      app: :mixduty,
      version: "0.2.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      name: "Mixduty",
      source_url: "https://github.com/PagerDuty/mixduty",
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        check: :test,
        dialyzer: :dev
      ],
      dialyzer: [
        # ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  defp description do
    """
    An elixir client for PagerDuty's API v2
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ian Minoso"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/PagerDuty/mixduty"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.2.2"},
      {:morphix, "~> 0.8.0"},
      {:plug_cowboy, "~> 2.6"},
      {:recode, "~> 0.6", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      check: [
        "clean",
        "check.fast",
        "test --warnings-as-errors --only integration"
      ],
      "check.fast": [
        "deps.unlock --check-unused",
        "compile --warnings-as-errors",
        "test --warnings-as-errors",
        "check.quality"
      ],
      "check.quality": [
        "format --check-formatted",
        "check.circular",
        "check.dialyzer",
        "recode"
      ],
      "check.circular": "cmd MIX_ENV=dev mix xref graph --label compile-connected --fail-above 0",
      "check.dialyzer": "cmd MIX_ENV=dev mix dialyzer"
    ]
  end
end
