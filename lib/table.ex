defmodule Fibril.Table do
  use Phoenix.Component

  import Fibril.CoreComponents

  alias Fibril.Resource
  alias Phoenix.HTML

  def fibril_column(%{display_type: :text} = assigns) do
    assigns =
      assigns
      |> assign(:text, get_text(assigns))
      |> assign(:description, get_description(assigns.field[:description], assigns))
      |> assign(:icon, get_icon(assigns.field[:icon], assigns))

    ~H"""
    <.fb_description description={@description} >
          <.fb_icon icon={@icon}>
          <span class={@text.classes}>
            <%= @text.value   %>
            </span>
          </.fb_icon>
    </.fb_description>
    """
  end

  def fibril_column(%{display_type: :textarea} = assigns) do
    assigns =
      assigns
      |> assign(:textarea, get_textarea(assigns))

    ~H"""
      <span class={@textarea.classes}>
        <%= @textarea.value   %>
      </span>
    """
  end

  def fibril_column(%{display_type: :date} = assigns) do
    assigns =
      assigns
      |> assign(:date, get_date(assigns))
      |> assign(:description, get_description(assigns.field[:description], assigns))
      |> assign(:icon, get_icon(assigns.field[:icon], assigns))

    ~H"""
    <.fb_description description={@description} >
          <.fb_icon icon={@icon}>
          <span class={@date.classes}>
            <%= @date.value   %>
            </span>
          </.fb_icon>
    </.fb_description>
    """
  end

  def fibril_column(%{display_type: :input} = assigns) do
    assigns =
      assigns
      |> assign(:name, get_name(assigns.field))
      |> assign(:input, get_input(assigns))
      |> assign(:description, get_description(assigns.field[:description], assigns))
      |> assign(:icon, get_icon(assigns.field[:icon], assigns))

    ~H"""
    <.fb_description description={@description} >
      <.fb_icon icon={@icon}>
        <input name={@name} type="text" label="Name" value={@input.value} id={@name} phx-hook="Edit"
          class={@input.classes}
          data-id={@record.id}
        />
        <div></div>
      </.fb_icon>
    </.fb_description>
    """
  end

  # Need to rework the :decimal column
  def fibril_column(%{display_type: :money} = assigns) do
    assigns =
      assigns
      |> assign(:money, get_money(assigns))
      |> assign(:description, get_description(assigns.field[:description], assigns))
      |> assign(:icon, get_icon(assigns.field[:icon], assigns))

    dbg(assigns.money)

    ~H"""
    <.fb_description description={@description} >
          <.fb_icon icon={@icon}>
          <span class={@money.classes}>
            <%= @money.value   %>
            <% dbg(@money.value) %>
            </span>
          </.fb_icon>
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
        class={@description.classes} >
          <%= @description.text %>
      </p>

      <%= render_slot(@inner_block) %>

      <p
        :if={@description && @description[:position] == :below}
        class={@description.classes}>
          <%= @description.text %>
      </p>
    """
  end

  def fb_icon(assigns) do
    ~H"""
      <.icon
        :if={@icon && @icon[:position] == :before}
        name={@icon.name}
        class={"h-4 w-4 ml-1 "<> (@icon.colour || "")}
      />

      <%= render_slot(@inner_block) %>

      <.icon
        :if={@icon && @icon[:position] == :after}
        name={@icon.name}
        class={"h-4 w-4 ml-1 "<> (@icon.colour || "")}
      />
    """
  end

  def get_text(assigns) do
    text = %{
      value: Resource.fetch_data(assigns.record, assigns.field),
      classes: [],
      attrs: []
    }

    format_text(text, assigns.field[:text], assigns)
  end

  def get_date(assigns) do
    date = %{
      value: Resource.fetch_data(assigns.record, assigns.field),
      classes: [],
      attrs: []
    }

    format_date(date, assigns.field[:date], assigns)
  end

  def get_textarea(assigns) do
    textarea = %{
      value: Resource.fetch_data(assigns.record, assigns.field),
      classes: ["whitespace-pre-line"],
      attrs: []
    }

    format_textarea(textarea, assigns.field[:textarea], assigns)
  end

  def get_input(assigns) do
    input = %{
      value: Resource.fetch_data(assigns.record, assigns.field),
      classes: [
        "border",
        "border-gray-300",
        "rounded-lg",
        "leading-9",
        "pl-4",
        "phx-no-feedback:border-gray-300",
        "phx-no-feedback:focus:border-orange-400",
        "phx-no-feedback:focus:border-2",
        "phx-no-feedback:focus:outline-none",
        "phx-no-feedback:focus:border-orange-400",
        "focus:outline-none",
        "focus:border-2",
        "focus:border-orange-400"
      ],
      attrs: []
    }

    format_input(input, assigns.field[:input], assigns)
  end

  def get_money(assigns) do
    money = %{
      value: Resource.fetch_data(assigns.record, assigns.field),
      classes: [],
      attrs: []
    }

    format_money(money, assigns.field[:money], assigns)
  end

  def format_text(text, options, _assigns) when is_nil(options) do
    text
  end

  def format_text(text, options, assigns) when is_map(options) do
    text
    |> get_colour(options[:colour], assigns)
    |> format_limit(options[:limit], assigns)
    |> format_words(options[:words], assigns)
    |> format_prefix(options[:prefix], assigns)
    |> format_suffix(options[:suffix], assigns)
    |> format_html(options[:html], assigns)
  end

  def format_textarea(textarea, options, _assigns) when is_nil(options) do
    textarea
  end

  def format_textarea(textarea, options, assigns) when is_map(options) do
    textarea
    |> get_colour(options[:colour], assigns)
    |> format_limit(options[:limit], assigns)
    |> format_words(options[:words], assigns)
    |> format_html(options[:html], assigns)
  end

  def format_date(date, options, _assigns) when is_nil(options) do
    date
  end

  def format_date(date, date_format, _assigns) when is_binary(date_format) do
    {:ok, value} = Timex.format(date.value, date_format, :strftime)
    %{date | value: value}
  end

  def format_date(date, options, assigns) when is_map(options) do
    date
    |> format_date(options[:format], assigns)
    |> get_colour(options[:colour], assigns)
  end

  def format_input(input, options, _assigns) when is_nil(options) do
    input
  end

  def format_input(input, options, assigns) when is_map(options) do
    input
    |> get_colour(options[:colour], assigns)
  end

  def format_money(money, options, _assigns) when is_nil(options) do
    money
  end

  def format_money(money, options, assigns) when is_map(options) do
    # N.B. Order matters here - need to finish any formatting before adding the
    # currency symbol.

    money
    |> format_amount(options[:divide_by], assigns)
    |> get_currency_symbol(options[:currency], assigns)
  end

  def get_description(options, _assigns) when is_nil(options) do
    nil
  end

  def get_description(description, assigns) when is_list(description) do
    apply_function(description, assigns)
  end

  def get_description(options, assigns) when is_map(options) do
    description = %{
      text: nil,
      position: nil,
      classes: ["text-sm", "text-gray-500", "dark:text-gray-400", "mb-1"],
      attrs: []
    }

    get_description(description, options, assigns)
  end

  def get_description(description, options, assigns) do
    description
    |> get_text(options[:text], assigns)
    |> get_position(options[:position], assigns)
    |> get_colour(options[:colour], assigns)
  end

  def format_limit(field, limit, _assigns) when is_nil(limit) do
    field
  end

  def format_limit(field, limit, _assigns) when is_number(limit) do
    %{field | value: String.slice(field.value, 0, limit) <> "..."}
  end

  def format_limit(field, limit, assigns) when is_list(limit) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, field.value)
    %{field | value: apply_function(limit, assigns)}
  end

  def format_words(field, words, _assigns) when is_nil(words) do
    field
  end

  def format_words(field, words, _assigns) when is_number(words) do
    text = String.split(field.value) |> Enum.take(words) |> Enum.join(" ")
    %{field | value: text <> "..."}
  end

  def format_words(field, words, assigns) when is_list(words) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, field.value)
    %{field | value: apply_function(words, assigns)}
  end

  def format_prefix(field, prefix, _assigns) when is_nil(prefix) do
    field
  end

  def format_prefix(field, prefix, _assigns) when is_binary(prefix) do
    %{field | value: prefix <> field.value}
  end

  def format_prefix(field, prefix, assigns) when is_list(prefix) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, field.value)
    apply_function(prefix, assigns)
  end

  def format_suffix(field, suffix, _assigns) when is_nil(suffix) do
    field
  end

  def format_suffix(field, suffix, _assigns) when is_binary(suffix) do
    %{field | value: field.value <> suffix}
  end

  def format_suffix(field, suffix, assigns) when is_list(suffix) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, field.value)
    %{field | value: apply_function(suffix, assigns)}
  end

  def format_html(field, _html = true, _assigns) do
    # text |> HTML.html_escape() |> HTML.safe_to_string()
    %{field | value: HTML.raw(field.value)}
  end

  def format_html(field, html, assigns) when is_list(html) do
    # Add formatted value to assigns so function can use it

    assigns = assign(assigns, :formatted_value, field.value)
    %{field | value: apply_function(html, assigns)}
  end

  def format_html(field, _html, _assigns) do
    field
  end

  def get_currency_symbol(money, currency, _assigns) when is_nil(currency) do
    money
  end

  def get_currency_symbol(money, currency, _assigns) when is_binary(currency) do
    %{money | value: currency <> money.value} |> dbg()
  end

  def get_currency_symbol(money, currency, assigns) when is_list(currency) do
    %{money | value: apply_function(currency, assigns)}
  end

  def format_amount(money, divide_by, _assigns) when is_nil(divide_by) do
    money
  end

  def format_amount(money, divide_by, _assigns) when is_number(divide_by) do
    dbg(money.value)
    {:ok, value} = Decimal.cast(money.value)

    %{
      money
      | value:
          value
          |> Decimal.div(divide_by)
          |> Decimal.round(2)
          |> Decimal.to_string()
    }
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
  def get_badge(field, options, _assigns) when is_nil(options) do
    field
  end

  def get_badge(field, options, _assigns) when is_boolean(options) do
    %{
      field
      | classes:
          if options do
            field.classes ++ ["badge"]
          else
            field.classes
          end
    }
  end

  def get_badge(field, options, assigns) when is_map(options) do
    field
    |> get_badge_colour(get_in(options, [:colours]), assigns)
    |> get_badge_outline(get_in(options, [:outline]), assigns)
  end

  defp get_badge_colour(field, colours, _assigns) when is_nil(colours) do
    field
  end

  defp get_badge_colour(field, colours, assigns) when is_map(colours) do
    %{field | classes: field.classes ++ ["badge", colours[assigns.raw_value]]}
  end

  defp get_badge_colour(field, colours, assigns) when is_list(colours) do
    %{field | classes: field.classes ++ [apply_function(colours, assigns)]}
  end

  defp get_badge_outline(field, outline, _assigns) when is_nil(outline) do
    field
  end

  defp get_badge_outline(field, outline, _assigns) when outline == true do
    %{field | classes: field.classes ++ ["badge", "badge-outline"]}
  end

  defp get_badge_outline(field, outline, assigns) when is_list(outline) do
    %{field | classes: field.classes ++ [apply_function(outline, assigns)]}
  end

  def get_colour(field, colour, _assigns) when is_nil(colour) do
    field
  end

  def get_colour(field, colour, _assigns) when is_binary(colour) do
    %{field | classes: field.classes ++ [colour]}
  end

  def get_colour(field, colour, assigns) when is_binary(colour) do
    %{field | classes: field.classes ++ [apply_function(colour, assigns)]}
  end

  def get_text(field, text, _assigns) when is_binary(text) do
    %{field | text: text}
  end

  def get_text(_field, text, assigns) when is_list(text) do
    apply_function(text, assigns)
  end

  def get_position(field, position, _assigns) when is_atom(position) do
    %{field | position: position}
  end

  def get_position(_field, position, assigns) when is_list(position) do
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

  # def format_date(value, date_format, _assigns) when is_nil(date_format) do
  #   value
  # end

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
