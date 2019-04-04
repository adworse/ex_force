defmodule ExForce.Types do
  defmacro __using__(_opts) do
    quote do
      @type client :: ExForce.Client.t()
      @type sobject_id :: String.t()
      @type sobject_name :: String.t()
      @type field_name :: String.t()
      @type soql :: String.t()
      @type query_id :: String.t()
    end
  end
end