pg_url = System.get_env("PG_URL") || "postgres:postgres@127.0.0.1"

Application.put_env(:fibril, Fibril.Endpoint,
  url: [host: "localhost", port: 4000],
  secret_key_base: "Hu4qQN3iKzTV4fJxhorPQlA/osH9fAMtbtjVS58PFgfw3ja5Z18Q/WSNR9wP4OfW",
  live_view: [signing_salt: "hMegieSe"],
  render_errors: [view: Fibril.ErrorView],
  check_origin: false,
  pubsub_server: FibrilTest.PubSub
)

defmodule Fibril.ErrorView do
  use Phoenix.View, root: "test/templates"

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule FibrilTest.Router do
  import FibrilWeb.Router

  use FibrilWeb, :router

  pipeline :browser do
    plug(:fetch_session)
  end

  scope "/" do
    pipe_through(:browser)

    admin()
  end
end

defmodule Fibril.Endpoint do
  use Phoenix.Endpoint, otp_app: :fibril

  plug(Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "/VEDsdfsffMnp5"
  )

  plug(FibrilTest.Router)
end

Application.ensure_all_started(:os_mon)

Application.put_env(:fibril, :ecto_repo, Fibril.Repo)
Application.put_env(:fibril, :session_store, FibrilTest.MockSession)

Supervisor.start_link(
  [
    {Phoenix.PubSub, name: FibrilTest.PubSub, adapter: Phoenix.PubSub.PG2},
    Fibril.Endpoint
  ],
  strategy: :one_for_one
)

ExUnit.start()
