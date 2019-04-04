defmodule ExForce.Client do
  @moduledoc """
  HTTP Client for Salesforce REST API using Tesla.

  ## Adapter

  To use different Tesla adapter, set it via Mix configuration.

  ```elixir
  config :tesla, ExForce.Client, adapter: Tesla.Adapter.Hackney
  ```
  """

  use Tesla
  plug Tesla.Middleware.Retry, delay: 500, max_retries: Application.get_env(:ex_force, :max_retries, 8)
  plug Tesla.Middleware.Timeout, timeout: Application.get_env(:ex_force, :timeout, 60_000)

  @type t :: Tesla.Client.t()

  @default_api_version "42.0"
  @default_user_agent "ex_force"

  @doc """

  Options

  - `:headers`: set additional headers; default: `[{"user-agent", "#{@default_user_agent}"}]`
  - `:api_version`: use the given api_version; default: `"#{@default_api_version}"`
  """
  def build(instance_url_or_map, opts \\ [headers: [{"user-agent", @default_user_agent}]])

  def build(%{instance_url: instance_url, access_token: access_token}, opts) do
    with headers <- Keyword.get(opts, :headers, []),
         new_headers <- [{"authorization", "Bearer " <> access_token} | headers],
         new_opts <- Keyword.put(opts, :headers, new_headers) do
      build(instance_url, new_opts)
    end
  end

  def build(instance_url, opts) when is_binary(instance_url) do
    Tesla.build_client([
      {ExForce.TeslaMiddleware,
       {instance_url, Keyword.get(opts, :api_version, @default_api_version)}},
      {Tesla.Middleware.Compression, format: "gzip"},
      {Tesla.Middleware.JSON, engine: Jason, engine_opts: [keys: :atoms]},
      {Tesla.Middleware.Headers, Keyword.get(opts, :headers, [])}
    ])
  end
end
