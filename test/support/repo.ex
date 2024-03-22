defmodule Fibril.Repo do
  # use Ecto.Repo, otp_app: :fibril, adapter: Ecto.Adapters.Postgres
  alias Fibril.Pets.Pet

  def all(_foo) do
    [%Pet{id: 1, name: "Foo"}, %Pet{id: 2, name: "Woo"}]
  end
end
