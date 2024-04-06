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
    module_prefix = Fibril.Schema.module_prefix() |> String.split(".")

    menu_items =
      Fibril.Schema.menu()
      |> Enum.map(fn module -> Module.split(module) end)
      |> Enum.filter(fn module -> List.starts_with?(module, module_prefix) end)
      |> Enum.map(fn module -> List.last(module) end)
      |> Enum.map(fn resource ->
        %{name: resource, url: Fibril.Schema.url_prefix() <> "/" <> resource}
      end)

    assigns = assign(assigns, :menu_items, menu_items)

    ~H"""
    <section class="fb-sidebar bg-gray-50 ">
        <div class="mt-6">
            <ul class="menu menu-md ">
            <%= for menu_item <- @menu_items do %>
            <div class={add_highlight(menu_item.name, @name)} >

                <li class="ml-4 mb-3">
                    <a href={menu_item.url}>
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
    <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 9.776c.112-.017.227-.026.344-.026h15.812c.117 0 .232.009.344.026m-16.5 0a2.25 2.25 0 0 0-1.883 2.542l.857 6a2.25 2.25 0 0 0 2.227 1.932H19.05a2.25 2.25 0 0 0 2.227-1.932l.857-6a2.25 2.25 0 0 0-1.883-2.542m-16.5 0V6A2.25 2.25 0 0 1 6 3.75h3.879a1.5 1.5 0 0 1 1.06.44l2.122 2.12a1.5 1.5 0 0 0 1.06.44H18A2.25 2.25 0 0 1 20.25 9v.776" />
    </svg>

                        <%= menu_item.name %>

                    </a>
                </li>
                </div>
              <% end %>
            </ul>
        </div>
    </section>
    """
  end

  def add_highlight(menu_name, name) do
    if menu_name == String.capitalize(name) do
      "text-orange-500"
    else
      " "
    end
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
