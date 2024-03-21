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
  end

  def get_metadata(type, field, schema) do
    apply(schema, :__schema__, [type, field])
  end

  def get_association(field, schema) do
    associations =
      apply(schema, :__schema__, [:associations])
      |> Enum.map(fn association ->
        apply(schema, :__schema__, [:association, association])
      end)

    Enum.find(associations, fn association -> association.owner_key == field end)
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
    apply(module, :__struct__, [])
  end

  def get_changeset(module, changeset, struct, attrs) when changeset == nil do
    apply(module, :changeset, [struct, attrs])
  end

  def get_changeset(module, changeset, struct, attrs) do
    apply(module, changeset, [struct, attrs])
  end
end
