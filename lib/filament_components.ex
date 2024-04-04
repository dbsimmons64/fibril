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

  def fibril_input(%{type: :integer} = assigns) do
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

  def fb_header(assigns) do
    ~H"""
    <header class="fb-header navbar border-b-2 border-gray-200">

    <div class="flex-1">
      <a class="btn btn-ghost text-xl">Laravel</a>
    </div>
    <div class="flex-none">
      <ul class="menu menu-horizontal px-1">
          <li><a>Link</a></li>
          <li>
              <details>
                  <summary>
                      Parent
                  </summary>
                  <ul class="p-2 bg-base-100 rounded-t-none">
                      <li><a>Link 1</a></li>
                      <li><a>Link 2</a></li>
                  </ul>
              </details>
          </li>
      </ul>
    </div>
    </header>
    """
  end

  def fb_sidebar(assigns) do
    ~H"""
    <section class="fb-sidebar bg-gray-50 ">
        <div class="mt-6">
            <ul class="menu menu-md ">
                <li class="ml-4 mb-3">
                    <a>
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-500" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                        </svg>
                        Dashboard
                    </a>
                </li>
                <li class="ml-4 mb-3">
                    <a>
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-500" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Item 1
                    </a>
                </li>
                <li class="ml-4 mb-3">
                    <a>
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-500" fill="none"
                            viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                        Item 3
                    </a>
                </li>
            </ul>
        </div>
    </section>
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
        assigns.fibril.association.queryable
      end

    query
    |> Ecto.Query.select([a], {field(a, ^name), a.id})
    |> Schema.repo().all()
  end
end
