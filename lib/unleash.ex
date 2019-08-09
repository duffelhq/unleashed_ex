defmodule Unleash do
  @moduledoc """
  If you have no plans on extending the client, then `Unleash` will be the main
  usage point of the library. Upon starting your app, the client is registered
  with the unleash server, and two `GenServer`s are started, one to fetch and
  poll for feature flags from the server, and one to send metrics.

  Configuring `:disable_client` to `true` disables both servers as well as
  registration, while configuring `:disable_metrics` to `true` disables only
  the metrics `GenServer`.
  """

  use Application
  require Logger

  alias Unleash.Client
  alias Unleash.Config
  alias Unleash.Feature
  alias Unleash.Metrics
  alias Unleash.Repo

  @typedoc """
  The context needed for a few activation strategies. Check their documentation
  for the required key.

  * `:user_id` is the ID of the user interacting _with your system_, can be any
    `String.t()`
  * `session_id` is the ID of the current session _in your system_, can be any
    `String.t()`
  * `remote_address` is the address of the user interacting _with your system_,
    can be any `String.t()`
  """
  @type context :: %{
          user_id: String.t(),
          session_id: String.t(),
          remote_address: String.t()
        }

  @doc """
  Aliased to `enabled?/2`
  """
  @spec is_enabled?(atom() | String.t(), boolean) :: boolean
  def is_enabled?(feature, default) when is_boolean(default),
    do: enabled?(feature, default)

  @doc """
  Aliased to `enabled?/3`
  """
  @spec is_enabled?(atom() | String.t(), Map.t(), boolean) :: boolean
  def is_enabled?(feature, context \\ %{}, default \\ false),
    do: enabled?(feature, context, default)

  @doc """
  Checks if the given feature is enabled. Checks as though an empty context was
  passed in.

  ## Examples

      iex> Unleash.enabled?(:my_feature, false)
      false

      iex> Unleash.enabled?(:my_feature, true)
      true
  """
  @spec enabled?(atom() | String.t(), boolean) :: boolean
  def enabled?(feature, default) when is_boolean(default),
    do: enabled?(feature, %{}, default)

  @doc """
  Checks if the given feature is enabled.

  If `:disable_client` is `true`, simply returns the given `default`.

  If `:disable_metrics` is `true`, nothing is logged about the given toggle.

  ## Examples

      iex> Unleash.enabled?(:my_feature)
      false

      iex> Unleash.enabled?(:my_feature, context)
      false

      iex> Unleash.enabled?(:my_feature, context, true)
      false
  """
  @spec enabled?(atom() | String.t(), Map.t(), boolean) :: boolean
  def enabled?(feature, context \\ %{}, default \\ false) do
    if Config.disable_client() do
      Logger.warn(fn ->
        "Client is disabled, it will only return default: #{default}"
      end)

      default
    else
      feature
      |> Repo.get_feature()
      |> case do
        %Feature{name: nil} -> {feature, default}
        feature -> {feature, Feature.enabled?(feature, context)}
      end
      |> Metrics.add_metric()
    end
  end

  @doc false
  def start(_type, _args) do
    children =
      [
        {Repo, Config.disable_client()},
        {Metrics, Config.disable_client() or Config.disable_metrics()}
      ]
      |> Enum.filter(fn {_m, not_enabled} -> not not_enabled end)
      |> Enum.map(fn {module, _e} -> module end)

    unless children == [] do
      Client.register_client()
    end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
