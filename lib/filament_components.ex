defmodule Fibril.FibrilComponents do
  require Ecto.Query
  use Phoenix.Component
  import Fibril.CoreComponents
  alias Fibril.Schema

  def fibril_input(%{type: :text} = assigns) do
    ~H"""
    <.input field={@field} type="text" label={@label} />
    """
  end

  def fibril_input(%{type: :association} = assigns) do
    ~H"""
    <.input field={@field} type="select" options={fetch_options(assigns)} label={@label} />
    """
  end

  def fibril_input(%{type: :date} = assigns) do
    ~H"""
    <.input field={@field} type="date" label={@label} />
    """
  end

  def fibril_input(%{type: :select} = assigns) do
    ~H"""
    <.input field={@field} type="select" options={assigns.fibril.options} label={@label} />
    """
  end

  @doc """
  Generate a label for the given field.

  The label itself can be based on:
    1. A simple atom e.g. :name, :date_of_birth
    2. A list [:owner, :name] generally used for associations
    3 A msp with a `label` key
    4. A map with a key of name: the value of which is an atom
    5. A map with a key of name: the value of which is a list

    A label based on a field name has the first letter capitalised and underscores replaced with
    spaces e..g `:date_of_birth` becomes `Date of birth`
  """
  def set_label(field) when is_atom(field) do
    create_label(field)
  end

  def set_label(field) when is_map(field) do
    field[:label] || set_label(field.name)
  end

  def set_label(field) when is_list(field) do
    set_label(List.last(field))
  end

  def create_label(name) do
    name
    |> Atom.to_string()
    |> String.capitalize()
    |> String.replace("_", " ")
  end

  def fetch_options(assigns) do
    name = assigns.fibril.value

    query =
      if assigns.fibril[:queryable] do
        assigns.fibril.queryable.()
      else
        assigns.fibril.assocation.queryable
      end

    query
    |> Ecto.Query.select([a], {field(a, ^name), a.id})
    |> Schema.repo().all()
  end
end
