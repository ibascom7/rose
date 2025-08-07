defmodule Rose.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RoseWeb.Telemetry,
      Rose.Repo,
      {DNSCluster, query: Application.get_env(:rose, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Rose.PubSub},
      # Start a worker by calling: Rose.Worker.start_link(arg)
      # {Rose.Worker, arg},
      # Start to serve requests, typically the last entry
      RoseWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rose.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RoseWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
