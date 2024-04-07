defmodule FibrilWeb.FibrilLive.FormComponent do
  use FibrilWeb, :live_component

  alias Fibril.Schema
  alias Fibril.Resource

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
     |> assign(:record, record)
     |> assign(:opts, form)}
  end

  @impl true
  def handle_event("validate", %{"fibril" => fibril_params}, socket) do
    changeset =
      Resource.get_changeset(socket.assigns.configuration, fibril_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "fibril"))}
  end

  def handle_event("save", %{"fibril" => fibril_params} = params, socket) do
    save_resource(socket, socket.assigns.action, fibril_params)
    # save_resource(socket, :new, fibril_params)
  end

  def handle_event("create-belongs-to", _params, socket) do
    {:noreply,
     socket
     |> assign(:action, :new_belongs_to)}
  end

  def handle_event("close-belongs-to", _params, socket) do
    {:noreply,
     socket
     |> assign(:action, :new)}
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
    preloads = Schema.create_preloads(table.fields)

    Resource.get_changeset(socket.assigns.configuration, attrs)
    |> Schema.repo().insert()
    |> Fibril.Helpers.preload(preloads)
  end

  def update_resource(socket, attrs \\ %{}) do
    table = apply(socket.assigns.configuration, :table, [])
    preloads = Schema.create_preloads(table.fields)

    Resource.get_changeset(
      socket.assigns.configuration,
      socket.assigns.record,
      attrs
    )
    |> Schema.repo().update()
    |> Fibril.Helpers.preload(preloads)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "fibril"))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
