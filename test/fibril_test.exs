defmodule FibrilTest do

  use FibrilWeb.ConnCase

  import Phoenix.LiveViewTest

  @endpoint Fibril.Endpoint
  @router FibrilTest.Router



  test "lists all pets", %{conn: conn} do



     live(conn, ~p"/admin/pets")

  end
end
