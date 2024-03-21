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

  scope "/" do
    pipe_through(:admin)
    live("/admin/:resource", FibrilWeb.FibrilLive.Index, :index)
    live("/admin/:resource/new", FibrilWeb.FibrilLive.Index, :new)
    live("/admin/:resource/:id/edit", FibrilWeb.FibrilLive.Index, :edit)
  end

  defmacro admin_resource(path, resource_mod) do
    import Phoenix.LiveView.Router, only: [live: 4]

    IO.puts("About to define Admin Resource!!!!!!!!!!!!")

    quote bind_quoted: [path: path, resource_mod: resource_mod] do
      live("/admin/:resource", FibrilWeb.FibrilLive.Index, :index)
      live("/admin/:resource/new", FibrilWeb.FibrilLive.Index, :new)
      live("/admin/:resource/:id/edit", FibrilWeb.FibrilLive.Index, :edit)
    end
  end
end
