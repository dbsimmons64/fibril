defmodule Fibril.Table do
  use Phoenix.Component

  def get_columns_metadata(columns, schema) do
    # Return the default column_type for the field

    Enum.map(columns, fn column -> get_column_metadata(column, schema) end)
  end

  def get_column_metadata(column, schema) when is_map(column) do
    get_column_metadata(column.name, schema)
    |> Map.merge(column, fn _k, _v1, v2 -> v2 end)
  end

  def get_column_metadata(column, schema) when is_atom(column) or is_list(column) do
    %{
      name: column,
      display_type: :text,
      ecto_type: get_metadata(:type, column, schema)
    }
  end

  def get_metadata(type, field, schema) do
    schema.__schema__(type, field)
    # apply(schema, :__schema__, [type, field])
  end
end

# fields: [
#   :description,
#   %{
#     name: :status,
#     html_type: :icon,
#     options: %{
#       ~c"New" => ~c"icon-1",
#       ~c"Issued" => ~c"icon-2",
#       ~c"Paid" => ~c"icon-3"
#     }
#   },
#   %{name: [:pet, :name], label: "Pet"}
# ]
