defmodule FibrilWeb.FibrilLive.FormComponent do
  use FibrilWeb, :live_component

  alias Fibril.Schema
  alias Fibril.Resource

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <div class="m-8">
            <div class="text-sm breadcrumbs">
                <ul>
                    <li><a>Patients</a></li>
                    <li><a>Create</a></li>
                </ul>
            </div>
            <div class="text-3xl font-bold">
                Create Patient
            </div>
        </div>

      <.simple_form
        for={@form}
        id="fibril-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="form"
      >
      <div class="grid grid-cols-2 gap-6 m-8">
        <%= for field <- @fields do %>
          <.fibril_input
            field={@form[field.name]}
            type={field.html_type}
            fibril={field}
            label={set_label(field)}
          />
        <% end %>
        </div>
        <:actions>
        <button class="btn bg-orange-500 hover:bg-orange-400 text-white m-8">Create</button>
          <.link patch={"#{@url_prefix}/#{@resource.plural}/new"}>

    </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{record: record} = assigns, socket) do
    resource = apply(assigns.configuration, :resource, [])
    form = apply(assigns.configuration, :form, [])

    fields = Schema.get_metadata_for_fields(form.fields, resource.module)
    changeset = Schema.get_changeset(resource.module, form[:changeset], record, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:fields, fields)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(resource: resource)
     |> assign(:form, to_form(changeset, as: "fibril"))
     |> assign(:opts, form)}
  end

  @impl true
  def handle_event("validate", %{"fibril" => fibril_params}, socket) do
    changeset =
      Resource.get_changeset(socket.assigns.configuration, fibril_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "fibril"))}
  end

  def handle_event("save", %{"fibril" => fibril_params}, socket) do
    save_resource(socket, socket.assigns.action, fibril_params)
    # save_resource(socket, :new, fibril_params)
  end

  defp save_resource(socket, :edit, fibril_params) do
    case update_resource(socket, fibril_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Pet updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_resource(socket, :new, fibril_params) do
    case create_resource(socket, fibril_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Pet created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def create_resource(socket, attrs \\ %{}) do
    table = apply(socket.assigns.configuration, :table, [])

    Resource.get_changeset(socket.assigns.configuration, attrs)
    |> Schema.repo().insert()
    |> Fibril.Helpers.preload(table[:preloads])
  end

  def update_resource(socket, attrs \\ %{}) do
    Resource.get_changeset(
      socket.assigns.configuration,
      socket.assigns.record,
      attrs
    )
    |> Schema.repo().update()
    |> Fibril.Helpers.preload(socket.assigns.opts[:preloads])
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "fibril"))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
