defmodule FibrilLive.BTFormComponent do
  use FibrilWeb, :live_component

  alias Fibril.Schema

  @impl true
  def render(assigns) do
    ~H"""
    <div>Hello</div>
    """
  end

  @impl true
  def update(assigns, socket) do
    # resource = apply(assigns.configuration, :resource, [])
    # form = apply(assigns.configuration, :form, [])

    # fields = Schema.get_metadata_for_fields(form.fields, resource.module)
    # changeset = Schema.get_changeset(resource.module, form[:changeset], record, %{})

    # {:ok,
    #  socket
    #  |> assign(assigns)
    #  |> assign(:fields, fields)
    #  |> assign(:url_prefix, Schema.url_prefix())
    #  |> assign(resource: resource)
    #  |> assign(:form, to_form(changeset, as: "fibril"))
    #  |> assign(:saturday, "Sunday")
    #  |> assign(:opts, form)}

    {:ok, socket |> assign(assigns)}
  end
end
