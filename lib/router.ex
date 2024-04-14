defmodule FibrilWeb.Router do
  use FibrilWeb, :router

  pipeline :admin do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {FibrilWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  defmacro fibril_admin(pipe) do
    import Phoenix.LiveView.Router, only: [live: 4]

    url_prefix = Application.get_env(:fibril, :url_prefix, "/admin")

    quote do
      scope unquote(url_prefix) do
        live_session :admin_user,
          on_mount: [{Fibril.Schema.auth(), :ensure_authenticated}] do
          pipe_through(unquote(pipe))
          live("/:resource", FibrilWeb.FibrilLive.Index, :index)
          live("/:resource/new", FibrilWeb.FibrilLive.Index, :new)
          live("/:resource/:id/edit", FibrilWeb.FibrilLive.Index, :edit)
        end
      end
    end
  end
end
