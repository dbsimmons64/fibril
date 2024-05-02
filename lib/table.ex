defmodule Fibril.Table do
  use Phoenix.Component

  import Fibril.CoreComponents

  alias Fibril.Resource
  alias Phoenix.HTML

  def fibril_column(%{display_type: :text} = assigns) do
    field = assigns.field
    assigns = assign(assigns, :raw_value, Resource.fetch_data(assigns.record, field))

    formatted_value =
      assigns.raw_value
      |> format_text(field[:text], assigns)
      |> format_html(field[:html], assigns)

    assigns = assign(assigns, :value, formatted_value)

    class =
      []
      |> get_badge(field[:badge], assigns)
      |> get_colour(field[:colour], assigns)
      |> Enum.uniq()

    assigns =
      assigns
      |> assign(:class, class)
      |> assign(:description, get_description(field[:description], assigns))
      |> assign(:icon, get_icon(field[:icon], assigns))

    ~H"""
    <.fb_description description={@description} >

        <span class={@class}>
          <.fb_icon icon={@icon}>
            <%= @value   %>
          </.fb_icon>
        </span>

    </.fb_description>
    """
  end

  def fibril_column(%{display_type: :textarea} = assigns) do
    field = assigns.field
    assigns = assign(assigns, :raw_value, Resource.fetch_data(assigns.record, field))

    formatted_value =
      assigns.raw_value
      |> format_text(field[:text], assigns)
      |> format_html(field[:html], assigns)

    assigns = assign(assigns, :value, formatted_value)

    class =
      []
      |> limit_lines(field[:text], assigns)

    ~H"""
          <span class="whitespace-pre-line">
            <%= @value   %>
            </span>
    """
  end

  def fibril_column(%{display_type: :input} = assigns) do
    field = assigns.field
    assigns = assign(assigns, :raw_value, Resource.fetch_data(assigns.record, field))

    assigns =
      assigns
      |> assign(:name, get_name(field))
      |> assign(:raw_value, Resource.fetch_data(assigns.record, field))

    class =
      []
      |> get_colour(field[:colour], assigns)
      |> Enum.uniq()

    assigns =
      assigns
      |> assign(:class, class)
      |> assign(:description, get_description(field[:description], assigns))

    ~H"""
    <.fb_description description={@description} >


        <input name={@name} type="text" label="Name" value={@raw_value} id={@name} phx-hook="Edit"
          class="border  border-gray-300  rounded-lg leading-9  pl-4 phx-no-feedback:border-gray-300 phx-no-feedback:focus:border-orange-400 phx-no-feedback:focus:border-2 phx-no-feedback:focus:outline-none phx-no-feedback:focus:border-orange-400 focus:outline-none focus:border-2 focus:border-orange-400"
          data-id={@record.id}
        />
        <div></div>


    </.fb_description>
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
      <%= @value  %>
    """
  end

  def fibril_column(%{display_type: :date} = assigns) do
    field = assigns.field
    assigns = assign(assigns, :raw_value, Resource.fetch_data(assigns.record, field))

    formatted_value =
      assigns.raw_value
      |> format_date(field[:datetime], assigns)

    assigns = assign(assigns, :value, formatted_value)

    class =
      []
      |> get_badge(field[:badge], assigns)
      |> get_colour(field[:colour], assigns)
      |> Enum.uniq()

    assigns =
      assigns
      |> assign(:class, class)
      |> assign(:description, get_description(field[:description], assigns))
      |> assign(:icon, get_icon(field[:icon], assigns))

    ~H"""
    <.fb_description description={@description} >

      <span class={@class}>
        <.fb_icon icon={@icon}>
          <%= @value  %>
        </.fb_icon>
      </span>

    </.fb_description>
    """
  end

  def fibril_column(%{display_type: :icon} = assigns) do
    field = assigns.field
    assigns = assign(assigns, :raw_value, Resource.fetch_data(assigns.record, field))

    assigns =
      assigns
      |> assign(:description, get_description(field[:description], assigns))
      |> assign(:icon, get_icon(field[:icon], assigns))

    ~H"""
      <.fb_description description={@description} >

        <.icon
          name={@icon.name}
          class={"ml-1 "<> "h-#{@icon.size.width} w-#{@icon.size.height} #{@icon.colour}"}
        />

      </.fb_description>
    """
  end

  def fibril_column(%{display_type: :boolean} = _assigns) do
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

  def fb_description(assigns) do
    ~H"""

      <p
        :if={@description && @description[:position] == :above}
        class="text-sm text-gray-500 dark:text-gray-400 mb-1">
          <%= @description.text %>
      </p>

      <%= render_slot(@inner_block) %>

      <p
        :if={@description && @description[:position] == :below}
        class="text-sm text-gray-500 dark:text-gray-400 mb-1">
          <%= @description.text %>
      </p>
    """
  end

  def fb_icon(assigns) do
    ~H"""
      <.icon
        :if={@icon && @icon[:position] == :before}
        name={@icon.name}
        class="h-4 w-4 mr-1"
      />

      <%= render_slot(@inner_block) %>

      <.icon
        :if={@icon && @icon[:position] == :after}
        name={@icon.name}
        class={"h-4 w-4 ml-1 "<> (@icon.colour || "")}
      />
    """
  end

  def format_text(text, text_opts, assigns) do
    text
    |> format_limit(text_opts[:limit], assigns)
    |> format_words(text_opts[:words], assigns)
    |> format_prefix(text_opts[:prefix], assigns)
    |> format_suffix(text_opts[:suffix], assigns)
  end

  def format_textarea(textarea, text_opts, assigns) do
    textarea
    |> format_limit(text_opts[:limit], assigns)
    |> format_words(text_opts[:words], assigns)
  end

  def format_limit(text, limit, _assigns) when is_nil(limit) do
    text
  end

  def format_limit(text, limit, _assigns) when is_number(limit) do
    String.slice(text, 0, limit) <> "..."
  end

  def format_limit(text, limit, assigns) when is_list(limit) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, text)
    apply_function(limit, assigns)
  end

  def format_words(text, words, _assigns) when is_nil(words) do
    text
  end

  def format_words(text, words, _assigns) when is_number(words) do
    text = String.split(text) |> Enum.take(words) |> Enum.join(" ")
    text <> "..."
  end

  def format_words(text, words, assigns) when is_list(words) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, text)
    apply_function(words, assigns)
  end

  def format_prefix(text, prefix, _assigns) when is_nil(prefix) do
    text
  end

  def format_prefix(text, prefix, _assigns) when is_binary(prefix) do
    prefix <> text
  end

  def format_prefix(text, prefix, assigns) when is_list(prefix) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, text)
    apply_function(prefix, assigns)
  end

  def format_suffix(text, suffix, _assigns) when is_nil(suffix) do
    text
  end

  def format_suffix(text, suffix, _assigns) when is_binary(suffix) do
    text <> suffix
  end

  def format_suffix(text, suffix, assigns) when is_list(suffix) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, text)
    apply_function(suffix, assigns)
  end

  def format_html(text, _html = true, _assigns) do
    # text |> HTML.html_escape() |> HTML.safe_to_string()
    HTML.raw(text)
  end

  def format_html(text, html, assigns) when is_list(html) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, text)
    apply_function(html, assigns)
  end

  def format_html(text, _html, _assigns) do
    text
  end

  def get_name(name) when is_atom(name) do
    name
  end

  def get_name(name) when is_map(name) do
    name.name
  end

  @doc """
  Retrieves the daisyUI class for a badge element based on the provided options.

  ## Parameters
  - `class`: A list of current classes associated with this column.
  - `options`: A map containing options for customizing the badge or nil if no badge is specified.
  - `assigns`: Assigns associated with the column used when one of the options is a function.

  ## Returns
  - Returns the original list of classes associated with the column and any additional classes for displaying a badge.

  ## Specification
  This function accepts the following `options`
  -  'colours'
  - 'outline'

  ## Examples
  ```elixir
  get_badge(
    [],
    %{
      colours: %{
        "Dog" => "badge-neutral",
        "Cat" => "badge-primary",
        "Rabbit" => "badge-secondary"
      },
      outline: true
    },
    %{}
  )
  # => ["badge", "badge-neutral", "badge", "badge-outline"]
  """
  def get_badge(class, options, _assigns) when is_nil(options) do
    class
  end

  def get_badge(class, options, _assigns) when is_boolean(options) do
    if options, do: class ++ ["badge"], else: class
  end

  def get_badge(class, options, assigns) when is_map(options) do
    class
    |> get_badge_colour(get_in(options, [:colours]), assigns)
    |> get_badge_outline(get_in(options, [:outline]), assigns)
  end

  defp get_badge_colour(class, colours, _assigns) when is_nil(colours) do
    class
  end

  defp get_badge_colour(class, colours, assigns) when is_map(colours) do
    class ++ ["badge", colours[assigns.raw_value]]
  end

  defp get_badge_colour(class, colours, assigns) when is_list(colours) do
    class ++ [apply_function(colours, assigns)]
  end

  defp get_badge_outline(class, outline, _assigns) when is_nil(outline) do
    class
  end

  defp get_badge_outline(class, outline, _assigns) when outline == true do
    class ++ ["badge", "badge-outline"]
  end

  defp get_badge_outline(class, outline, assigns) when is_list(outline) do
    class ++ [apply_function(outline, assigns)]
  end

  def get_colour(class, colour, _assigns) when is_nil(colour) do
    class
  end

  def get_colour(class, colour, _assigns) when is_binary(colour) do
    class ++ [colour]
  end

  def get_colour(class, colour, assigns) when is_binary(colour) do
    class ++ [apply_function(colour, assigns)]
  end

  def get_description(description, _assigns) when is_nil(description) do
    nil
  end

  def get_description(description, assigns) when is_map(description) do
    dbg(assigns)

    %{
      text: get_description_text(description[:text], assigns),
      position: get_description_position(description[:position], assigns)
    }
  end

  def get_description(description, assigns) when is_list(description) do
    apply_function(description, assigns)
  end

  def get_description_text(text, _assigns) when is_binary(text) do
    text
  end

  def get_description_text(text, assigns) when is_list(text) do
    apply_function(text, assigns)
  end

  def get_description_position(position, _assigns) when is_atom(position) do
    position
  end

  def get_description_position(position, assigns) when is_list(position) do
    apply_function(position, assigns)
  end

  def get_icon(icon, _assigns) when is_nil(icon) do
    nil
  end

  def get_icon(icon, _assigns) when is_binary(icon) do
    %{
      name: icon,
      position: :before,
      colour: nil,
      size: %{width: 5, height: 5}
    }
  end

  def get_icon(icon, assigns) when is_map(icon) do
    %{
      name: get_icon_name(icon[:name], assigns),
      position: get_icon_position(icon[:position], assigns),
      colour: get_icon_colour(icon[:colour], assigns),
      size: get_icon_size(icon[:size], assigns)
    }
  end

  def get_icon(icon, assigns) when is_list(icon) do
    apply_function(icon, assigns)
  end

  def get_icon_name(name, _assigns) when is_binary(name) do
    name
  end

  def get_icon_name(name, assigns) when is_map(name) do
    name[assigns.raw_value]
  end

  def get_icon_name(name, assigns) when is_list(name) do
    apply_function(name, assigns)
  end

  def get_icon_position(position, _assigns) when is_nil(position) do
    :before
  end

  def get_icon_position(position, _assigns) when is_atom(position) do
    position
  end

  def get_icon_position(position, assigns) when is_list(position) do
    apply_function(position, assigns)
  end

  def get_icon_colour(colour, _assigns) when is_nil(colour) do
    nil
  end

  def get_icon_colour(colour, _assigns) when is_binary(colour) do
    colour
  end

  def get_icon_colour(colour, assigns) when is_list(colour) do
    apply_function(colour, assigns)
  end

  def get_icon_size(size, _assigns) when is_nil(size) do
    %{height: 5, width: 5}
  end

  def get_icon_size(size, _assigns) when is_map(size) do
    size
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
      ecto_type: get_metadata(:type, column, schema),
      display_type: get_metadata(:type, column, schema) |> get_display_type()
    }
  end

  def get_metadata(type, field, schema) do
    schema.__schema__(type, field)
  end

  def get_display_type(:integer) do
    :integer
  end

  def get_display_type(:date) do
    :date
  end

  def get_display_type(:decimal) do
    :decimal
  end

  def get_display_type(_ecto_type) do
    :text
  end
end
