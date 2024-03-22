defmodule FibrilTest do

  use FibrilWeb.ConnCase

  import Phoenix.LiveViewTest

  @endpoint Fibril.Endpoint
  @router FibrilTest.Router



  test "lists all pets", %{conn: conn} do



    {:ok, _view, html} = live(conn, ~p"/admin/pets")
    assert html =~ "Foo"


  end
end
