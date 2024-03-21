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

  def set_label(field) do
    field[:label] || create_label(field.name)
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
