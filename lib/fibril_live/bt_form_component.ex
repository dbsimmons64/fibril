defmodule FibrilLive.BTFormComponent do
  use FibrilWeb, :live_component

  alias Fibril.Resource
  alias Fibril.Schema

  @impl true
  def render(assigns) do
    ~H"""
    <div>
       <.simple_form
        for={@form}
        id="fibril-btform"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="form"
      >
      <div class="grid grid-cols-2 gap-6 m-8">
        <%= for field <- @fields do %>
          <.fibril_input
            name={@form[field.name]}
            type={field.html_type}
            field={field}
            myself={@myself}
            label={set_label(field)}
          />


        <% end %>
        </div>
        <:actions>
        <button class="btn bg-orange-500 hover:bg-orange-400 text-white m-8">Create</button>
          <.link patch={"#{@url_prefix}/owners/new"}>

    </.link>
        </:actions>
      </.simple_form>
      </div>
    """
  end

  @impl true
  def update(%{record: record} = assigns, socket) do
    field = assigns.field
    module = field.association.related
    fields = Schema.get_metadata_for_fields(field.createOptionForm.fields, module)
    changeset = Schema.get_changeset(module, field.createOptionForm[:changeset], record, %{})

    # Warning HARD CODED!!!!!!!!!!
    resource = :owner

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:fields, fields)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(:form, to_form(changeset, as: "fibril2"))
     |> assign(:resource, resource)
     |> assign(:record, record)}
  end

  @impl true
  def handle_event("validate", %{"fibril2" => fibril_params}, socket) do
    field = socket.assigns.field
    module = field.association.related

    changeset =
      Schema.get_changeset(
        module,
        field.createOptionForm[:changeset],
        Schema.get_struct(module),
        fibril_params
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "fibril2"))}
  end
end
