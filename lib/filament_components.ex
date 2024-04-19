defmodule Fibril.FibrilComponents do
  require Ecto.Query
  use Phoenix.Component
  import Fibril.CoreComponents
  alias Fibril.Resource
  alias Fibril.Schema

  def fibril_input(%{type: :text} = assigns) do
    ~H"""
    <.input field={@name} type="text" label={@label} />
    """
  end

  def fibril_input(%{type: :integer} = assigns) do
    ~H"""
    <.input field={@name} type="text" label={@label} class="badge" />
    """
  end

  def fibril_input(%{type: :decimal} = assigns) do
    ~H"""
    <.input field={@name} type="text" label={@label} class="badge" />
    """
  end

  def fibril_input(%{type: :association} = assigns) do
    ~H"""
    <div class="flex ">
    <div class="w-full">
    <.input field={@name} type="select" options={fetch_options(assigns)} label={@label} />
    </div>

    <div :if={@field[:createOptionForm]}>
      <div
      class="border border-gray-300 mt-6 ml-2 p-3 rounded-lg"
        phx-click="open-belongs-to",
        phx-target={@myself}
        phx-value-name={@field.name}>
        <.icon name="hero-plus" class="h-4 w-4 text-gray-300" />
      </div>
    </div>
    </div>
    """
  end

  def fibril_input(%{type: :date} = assigns) do
    ~H"""
    <.input field={@name} type="date" label={@label} />
    """
  end

  def fibril_input(%{type: :select} = assigns) do
    ~H"""
    <.input field={@name} type="select" options={@field.options} label={@label} />
    """
  end

  def fibril_column(%{display_type: :text} = assigns) do
    # What can impact a display type:
    #
    # Prefixes e.g. money symbol or icon
    # classes associated with the data e.g text size or text colour.
    # format of the data e.g. decimal places or maximum length of text
    # Suffixes e.g. icon or suffix

    raw_value = Resource.fetch_data(assigns.record, assigns.field)

    formatted_value =
      raw_value

    assigns = assign(assigns, :value, formatted_value)

    class =
      []
      |> get_badge(raw_value, get_in(assigns.field, [:badge]), assigns)
      |> Enum.uniq()

    assigns = assign(assigns, :class, class)

    ~H"""

    <.description_above field={@field} />
    <div class={@class}>
      <%= @value   %>
    </div>
    <.description_below field={@field} />
    """
  end

  # Need to rework the :decimal column
  def fibril_column(%{display_type: display_type} = assigns)
      when display_type in [:decimal, :integer] do
    raw_value = Resource.fetch_data(assigns.record, assigns.field)

    formatted_value =
      raw_value
      |> format_money(get_in(assigns.field, [:money]), assigns)
      |> format_date(get_in(assigns.field, [:datetime]), assigns)

    assigns =
      assigns
      |> assign(:value, formatted_value)
      |> assign(:raw_value, raw_value)

    ~H"""

    <.description_above field={@field} />


      <%= @value  %>

    <.description_below field={@field} />
    """
  end

  def fibril_column(%{display_type: :date} = assigns) do
    # badge_class = get_badge(assigns)

    value =
      Resource.fetch_data(assigns.record, assigns.field)
      |> format_date(get_in(assigns.field, [:datetime]), assigns)

    assigns = assign(assigns, :value, value)

    ~H"""
    <.description_above field={@field} />
      <%= @value  %>
    <.description_below field={@field} />
    """
  end

  def fibril_column(%{display_type: :icon} = assigns) do
    column_value = Resource.fetch_data(assigns.record, assigns.field)
    assigns = assign(assigns, :icon, assigns.field.options[column_value])

    ~H"""
    <.icon name={@icon} class="h-5 w-5" />
    """
  end

  def fibril_column(%{display_type: :calculated} = assigns) do
    [func | args] = assigns.field.calculation

    args = Enum.map(args, fn arg -> assigns[arg] end)
    result = apply(func, args)
    assigns = assign(assigns, :result, result)

    ~H"""
    <%= @result %>
    """
  end

  def apply_function(list, assigns) do
    [func | args] = list

    args = Enum.map(args, fn arg -> assigns[arg] end)
    apply(func, args)
  end

  def description_above(assigns) do
    if assigns.field[:description] && assigns.field.description[:position] == :above do
      ~H"""
      <p class="text-sm text-gray-500 dark:text-gray-400 mb-1">
        <%= @field.description.text %>
      </p>
      """
    else
      ~H"""
      """
    end
  end

  def description_below(assigns) do
    if assigns.field[:description] && assigns.field.description[:position] != :above do
      ~H"""
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
        <%= @field.description.text %>
      </p>
      """
    else
      ~H"""
      """
    end
  end

  def get_badge(class, _value, options, _assigns) when is_nil(options) do
    class
  end

  def get_badge(class, value, options, assigns) when is_map(options) do
    class
    |> get_badge_colour(value, get_in(options, [:colours]), assigns)
    |> get_badge_outline(value, get_in(options, [:outline]), assigns)
  end

  def get_badge_colour(class, _value, colours, _assigns) when is_nil(colours) do
    class
  end

  def get_badge_colour(class, value, colours, _assigns) when is_map(colours) do
    class ++ ["badge", colours[value]]
  end

  def get_badge_colour(class, _value, colours, assigns) when is_list(colours) do
    class ++ [apply_function(colours, assigns)]
  end

  def get_badge_outline(class, _value, outline, _assigns) when is_nil(outline) do
    class
  end

  def get_badge_outline(class, _value, outline, _assigns) when outline == true do
    class ++ ["badge", "badge-outline"]
  end

  def get_badge_outline(class, _value, outline, assigns) when is_list(outline) do
    class ++ [apply_function(outline, assigns)]
  end

  def format_money(value, money, _assigns) when is_nil(money) do
    value
  end

  def format_money(value, money, assigns) when is_map(money) do
    value
    |> format_divide_by(get_in(money, [:divide_by]), assigns)
    |> Decimal.to_string()
    |> format_currency(get_in(money, [:currency]), assigns)
  end

  def format_currency(value, currency, _assigns) when is_nil(currency) do
    value
  end

  def format_currency(value, currency, _assigns) when is_binary(currency) do
    currency <> value
  end

  def format_divide_by(value, divisor, _assigns) when is_nil(divisor) do
    value
  end

  def format_divide_by(value, divisor, _assigns) when is_number(divisor) do
    Decimal.div(value, Decimal.new(divisor)) |> Decimal.round(2)
  end

  def format_date(value, date_format, _assigns) when is_nil(date_format) do
    value
  end

  def format_date(value, date_format, _assigns) when is_binary(date_format) do
    {:ok, value} = Timex.format(value, date_format, :strftime)
    value
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

  def show_field(option, _assigns) when is_nil(option) do
    true
  end

  def show_field(option, _assigns) when is_atom(option) do
    !option
  end

  def show_field(option, assigns) when is_list(option) do
    [func | args] = option

    args = Enum.map(args, fn arg -> assigns[arg] end)
    apply(func, args)
  end

  def show_field(field) when is_list(field) do
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
    name = assigns.field.value

    query =
      if assigns.field[:queryable] do
        assigns.field.queryable.()
      else
        assigns.field.association.queryable
      end

    query
    |> Ecto.Query.select([a], {field(a, ^name), a.id})
    |> Schema.repo().all()
  end
end
