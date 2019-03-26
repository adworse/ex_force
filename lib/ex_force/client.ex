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
  plug Tesla.Middleware.Retry, delay: 500, max_retries: Application.get_env(:ex_force, :max_retries, 3)
  plug Tesla.Middleware.Timeout, timeout: Application.get_env(:ex_force, :timeout, 10_000)

  @type t :: Tesla.Client.t()
end
