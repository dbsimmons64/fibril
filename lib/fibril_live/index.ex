defmodule FibrilWeb.FibrilLive.Index do
  use FibrilWeb, :live_view

  alias Fibril.Resource
  alias Fibril.Schema

  @impl true
  def mount(%{"resource" => resource}, _session, socket) do
    configuration = Module.concat([Schema.module_prefix(), String.capitalize(resource)])

    resource = configuration.resource
    table = configuration.table

    preloads = Schema.create_preloads(table.fields)

    {:ok,
     socket
     |> assign(:configuration, configuration)
     |> assign(:url_prefix, Schema.url_prefix())
     |> assign(resource: resource)
     |> assign(:fields, table.fields)
     |> assign(:preloads, preloads)}
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

  defp apply_action(socket, :index, params) do
    params = Map.merge(%{"page" => 1, "page_size" => 2}, params)

    resource = socket.assigns.configuration.resource

    {:ok, {records, meta}} =
      Resource.list_records(resource.module, socket.assigns.preloads, params)

    socket
    |> assign(:meta, meta)
    |> assign(:page_title, String.capitalize(socket.assigns.resource.plural))
    |> assign(:pet, nil)
    |> stream(:records, records, reset: true)
  end

  @impl true
  def handle_info({FibrilWeb.FibrilLive.FormComponent, {:saved, _record}}, socket) do
    #    {:noreply, stream_insert(socket, :records, record)}
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    resource = apply(socket.assigns.configuration, :resource, [])
    record = Schema.repo().get!(resource.module, id)

    {:ok, _} = Schema.repo().delete(record)

    {:noreply, stream_delete(socket, :records, record)}
  end
end
