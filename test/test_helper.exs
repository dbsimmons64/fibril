pg_url = System.get_env("PG_URL") || "postgres:postgres@127.0.0.1"

# Application.put_env(:fibril, FibrilTest.Repo,
#   url: "ecto://#{pg_url}/phx_admin_dev",
#   pool: Ecto.Adapters.SQL.Sandbox
# )

# defmodule FibrilTest.Repo do
#   use Ecto.Repo, otp_app: :live_admin, adapter: Ecto.Adapters.Postgres

#   def prefixes, do: ["alt"]
# end

Application.put_env(:fibril, Fibril.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "fibril_test",
  pool: Ecto.Adapters.SQL.Sandbox
)

# _ = Ecto.Adapters.Postgres.storage_up(Fibril.Repo.config())

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
  use Phoenix.Router

  import FibrilWeb.Router

  use FibrilWeb, :router

  pipeline :browser do
    plug(:fetch_session)
  end

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {FibrilWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end
  scope "/" do
    pipe_through(:browser)

    admin()
  end
  scope "/" do
    pipe_through(:admin)
    live("/admin/:resource", FibrilWeb.FibrilLive.Index, :index)
    live("/admin/:resource/new", FibrilWeb.FibrilLive.Index, :new)
    live("/admin/:resource/:id/edit", FibrilWeb.FibrilLive.Index, :edit)
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

defmodule FibrilTest.StubSession do
  @behaviour Fibril.Session.Store

  def init!(_), do: "fake"
  # def load!(_), do: %Fibril.Session{}
  def persist!(_), do: :ok
end

# Mox.defmock(FibrilTest.MockSession,
#   for: Fibril.Session.Store,
#   skip_optional_callbacks: true
# )

Application.ensure_all_started(:os_mon)

Application.put_env(:fibril, :ecto_repo, Fibril.Repo)
Application.put_env(:fibril, :session_store, FibrilTest.MockSession)

Supervisor.start_link(
  [
    # Fibril.Repo,
    {Phoenix.PubSub, name: FibrilTest.PubSub, adapter: Phoenix.PubSub.PG2},
    Fibril.Endpoint
  ],
  strategy: :one_for_one
)

# FibrilTest.Repo.delete_all(FibrilTest.User)
# FibrilTest.Repo.delete_all(FibrilTest.Post)
# FibrilTest.Repo.delete_all(FibrilTest.User, prefix: "alt")
# FibrilTest.Repo.delete_all(FibrilTest.Post, prefix: "alt")

ExUnit.start()

# Ecto.Adapters.SQL.Sandbox.mode(Fibril.Repo, :manual)
