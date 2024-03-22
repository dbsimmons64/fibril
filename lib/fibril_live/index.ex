defmodule FibrilWeb.FibrilLive.Index do
  use FibrilWeb, :live_view

  alias Fibril.Resource
  alias Fibril.Schema

  @impl true
  def mount(%{"resource" => resource}, _session, socket) do

    configuration = Module.concat(["FibrilWeb.Fibril.Resourcces", String.capitalize(resource)])
    resource = apply(configuration, :resource, [])
    table = apply(configuration, :table, [])

    {:ok,
     socket
     |> assign(:configuration, configuration)
     |> assign(resource: resource)
     |> assign(:fields, table.fields)
     |> stream(:records, Resource.list_records(resource.module, table[:preloads]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    resource = apply(socket.assigns.configuration, :resource, [])
    record = Schema.repo().get!(resource.module, id)

    socket
    |> assign(:page_title, "Edit #{String.capitalize(resource.name)}")
    |> assign(resource: resource)
    |> assign(:record, record)
  end

  defp apply_action(socket, :new, _params) do
    resource = apply(socket.assigns.configuration, :resource, [])

    socket
    |> assign(:page_title, "New #{String.capitalize(resource.name)}")
    |> assign(:record, Schema.get_struct(resource.module))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing #{socket.assigns.resource.plural}")
    |> assign(:pet, nil)
  end

  @impl true
  def handle_info({FibrilWeb.FibrilLive.FormComponent, {:saved, record}}, socket) do
    {:noreply, stream_insert(socket, :records, record)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    resource = apply(socket.assigns.configuration, :resource, [])
    record = Schema.repo().get!(resource.module, id)

    {:ok, _} = Schema.repo().delete(record)

    {:noreply, stream_delete(socket, :records, record)}
  end

  def fetch_data(record, fields) when is_list(fields) do
    keys = Enum.map(fields, fn field -> Access.key(field, %{}) end)
    get_in(record, keys)
  end

  def fetch_data(record, field) do
    Map.get(record, field)
  end
end
