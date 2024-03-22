defmodule FibrilWeb.Router do
  use FibrilWeb, :router



  defmacro admin() do
    import Phoenix.LiveView.Router, only: [live: 4]

    quote  do
      live("/admin/:resource", FibrilWeb.FibrilLive.Index, :index)
      live("/admin/:resource/new", FibrilWeb.FibrilLive.Index, :new)
      live("/admin/:resource/:id/edit", FibrilWeb.FibrilLive.Index, :edit)
    end
  end

end
