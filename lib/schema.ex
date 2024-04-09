defmodule Fibril.Schema do
  use Fibril.Config

  def get_metadata_for_fields(fields, schema) do
    Enum.map(fields, fn field ->
      get_metadata_for_field(field, schema)
    end)
  end

  def get_metadata_for_field(field, schema) when is_map(field) do
    get_metadata_for_field(field.name, schema)
    |> Map.merge(field, fn _k, _v1, v2 -> v2 end)
  end

  def get_metadata_for_field(field, schema) when is_atom(field) do
    if field in schema.__schema__(:fields) do
      field_metadata = %{
        name: field,
        ecto_type: get_metadata(:type, field, schema),
        html_type: get_metadata(:type, field, schema) |> to_html_type()
      }

      if field_metadata.ecto_type == :id do
        Map.put(field_metadata, :association, get_association(field, schema))
      else
        field_metadata
      end
    else
      raise """
      Field Error

      #{field} is not in schema, #{schema}.

      Valid fields are #{inspect(schema.__schema__(:fields))}.
      """
    end
  end

  def get_metadata(type, field, schema) do
    schema.__schema__(type, field)
    # apply(schema, :__schema__, [type, field])
  end

  def get_association(field, schema) do
    associations =
      schema.__schema__(:associations)
      # apply(schema, :__schema__, [:associations])
      |> Enum.map(fn association ->
        schema.__schema__(:association, association)
        # apply(schema, :__schema__, [:association, association])
      end)

    Enum.find(associations, fn association -> association.owner_key == field end)
  end

  def create_preloads(fields) do
    # Return all fields that require a preload

    Enum.map(fields, fn field -> get_preload(field) end)
    |> Enum.filter(fn result -> result != nil end)
  end

  def get_preload(field) when is_atom(field) do
    nil
  end

  def get_preload(field) when is_map(field) do
    get_preload(field.name)
  end

  def get_preload(field) when is_list(field) do
    # Remove the last element of the list which represents field name
    [first | rest] = Enum.drop(field, -1)
    list_to_preload(first, rest)
  end

  @doc """
  Receive a field that relies on preloading a resource and return the correct argument to
  pass to a preload function.

  ## Examples


       [:pet, :name] => preload: [:pet]

       [:pet, :owner, :name] => preload: [pet: :owner]

       [:foo, :bar, :baz, :wibble, :field_name] => preload: [foo: [bar: :wibble]]

  """

  def list_to_preload(first, []) do
    [first]
  end

  def list_to_preload(key, value) do
    [first | rest] = value
    %{key => list_to_preload(first, rest)} |> Map.to_list()
  end

  @doc """
  Convert the Ecto type to a suitable HTML input type.

  The Ecto type and the HTML type don't map 1 to 1.
  For example :string in Ecto is a :text in HTML.
  """
  def to_html_type(:string) do
    :text
  end

  def to_html_type(:id) do
    :association
  end

  def to_html_type(type) do
    type
  end

  def get_struct(module) do
    module.__struct__()
    # apply(module, :__struct__, [])
  end

  @doc """
  Returns the given changeset for the module

  If no changeset is given then a default of :changeset is assumed.


   Vet.Owners.Owner,
  nil,
  %Vet.Owners.Owner{
    __meta__: #Ecto.Schema.Metadata<:built, "owners">,
    id: nil,
    name: nil,
    pets: #Ecto.Association.NotLoaded<association :pets is not loaded>,
    inserted_at: nil,
    updated_at: nil
  },
  %{}
  """
  def get_changeset(module, changeset, schema, attrs) when changeset == nil do
    apply(module, :changeset, [schema, attrs])
  end

  def get_changeset(module, changeset, schema, attrs) do
    apply(module, changeset, [schema, attrs])
  end
end
