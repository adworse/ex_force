defmodule ExForce.Composite do
  @moduledoc """
  ### Create
  data = [%{"Name" => "Apptopia"},
          %{"Name" => "Bloomberg", "type" => "Company"}]

  ExForce.Composite.sobjects_collections_create(client, data, object_type: "Account")

  ### Update
   ```elixir
    data = [%{"Name" => "Apptopia", "Id" => "0010Q00000JSr9zQAD"},
            %{"Name" => "Bloomberg", "Id" => "0010Q00000JSrEkQAL"}]

    ExForce.Composite.sobjects_collections_update(client, data, object_type: "Account")
    {:ok,
     [
       %ExForce.Composite.SaveResultObject{
         errors: [],
         id: "0010Q00000JSr9zQAD",
         success: true
       },
       %ExForce.Composite.SaveResultObject{
         errors: [],
         id: "0010Q00000JSrEkQAL",
         success: true
       }]
    }
  ```
  """

  import ExForce.Client, only: [request: 2]
  alias ExForce.{SObject, Composite.SaveResultObject}

  use ExForce.Types

  @doc """
  Retrieve Multiple Records

  See [Retrieve Multiple Records with Fewer Round-Trips](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_composite_sobjects_collections_retrieve.htm)
  """
  @spec sobjects_collections_retrieve(client, sobject_name, list, list) :: {:ok, list(SObject.t())} | {:error, any}
  def sobjects_collections_retrieve(client, name, ids, fields) do
    composite_body = %{"ids" => ids, "fields" => fields}

    case request(client, method: :post, url: "composite/sobjects/#{name}", body: composite_body) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, Enum.map(body, &SObject.build/1)}
      {:ok, %Tesla.Env{body: body}} -> {:error, body}
      {:error, _} = other -> other
    end
  end

  @doc """
  Retrieve Multiple Records

  See [Update Multiple Records with Fewer Round-Trips](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_composite_sobjects_collections_update.htm)
  """
  @spec sobjects_collections_update(client, list, keyword) :: {:ok, list(SaveResultObject.t)} | {:error, any}
  def sobjects_collections_update(client, objects, opts \\ []) do
    create_or_update(client, :patch, objects, opts)
  end

  @doc """
  Retrieve Multiple Records

  See [Create Multiple Records with Fewer Round-Trips](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_composite_sobjects_collections_create.htm)
  """
  @spec sobjects_collections_create(client, list, keyword) :: {:ok, list(SaveResultObject.t)} | {:error, any}
  def sobjects_collections_create(client, objects, opts \\ []) do
    create_or_update(client, :post, objects, opts)
  end

  defp create_or_update(client, method, objects, opts) do
    all_or_none = Keyword.get(opts, :all_or_none, false)

    records = Enum.map(objects, fn(object) ->
      %{attributes: %{type:  Keyword.get(opts, :object_type, object["type"])}}
      |> Map.merge(object)
      |> Map.drop(["type"])
    end)

    composite_body = %{allOrNone: all_or_none, records: records}

    case request(client, method: method, url: "composite/sobjects", body: composite_body) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body |> Enum.map(& struct(SaveResultObject, &1))}
      {:ok, %Tesla.Env{body: body}} -> {:error, body}
      {:error, _} = other -> other
    end
  end
end