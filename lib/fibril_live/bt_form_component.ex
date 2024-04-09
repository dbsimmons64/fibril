defmodule FibrilLive.BTFormComponent do
  use FibrilWeb, :live_component

  alias Fibril.Schema

  @impl true
  def render(assigns) do
    ~H"""
    <div>
       <.simple_form
        for={@bt_form}
        id="fibril-btform"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="form"
      >
      <div class="grid grid-cols-2 gap-6 m-8">
        <%= for field <- @fields do %>
          <.fibril_input
            name={@bt_form[field.name]}
            type={field.html_type}
            field={field}
            myself={@myself}
            label={set_label(field)}
          />
        <% end %>
        </div>
        <:actions>
        <button class="btn bg-orange-500 hover:bg-orange-400 text-white m-8">Create</button>
          <.link patch={"#{@url_prefix}/resource/new"}></.link>
        </:actions>
      </.simple_form>
      </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    field = assigns.field
    module = field.association.related
    fields = Schema.get_metadata_for_fields(field.createOptionForm.fields, module)

    record = Schema.get_struct(module)

    changeset = Schema.get_changeset(module, field.createOptionForm[:changeset], record, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:fields, fields)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(:bt_form, to_form(changeset, as: "fibril2"))
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

    {:noreply, assign(socket, :bt_form, to_form(changeset, as: "fibril2"))}
  end

  def handle_event("save", %{"fibril2" => fibril_params}, socket) do
    save_resource(socket, :new, fibril_params)
  end

  defp save_resource(socket, :new, fibril_params) do
    case create_resource(socket, fibril_params) do
      {:ok, resource} ->
        # Let the parent form know about the newly created resource so it can do its thing
        notify_parent(
          socket.assigns.parent_form,
          %{
            field_name: socket.assigns.field.name,
            resource: resource
          }
        )

        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def create_resource(socket, attrs \\ %{}) do
    field = socket.assigns.field
    module = field.association.related

    changeset =
      Schema.get_changeset(
        module,
        field.createOptionForm[:changeset],
        Schema.get_struct(module),
        attrs
      )

    changeset
    |> Schema.repo().insert()
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :bt_form, to_form(changeset, as: "fibril2"))
  end

  defp notify_parent(parent, msg), do: send_update(parent, msg)
end
