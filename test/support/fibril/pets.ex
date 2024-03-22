defmodule FibrilWeb.Fibril.Resourcces.Pets do
  import Ecto.Query, warn: false

  def resource do
    %{module: Vet.Pets.Pet, name: "pet", plural: "pets"}
  end

  def table() do
    %{
      fields: [:name, :date_of_birth]
    }
  end

  def form() do
    %{
      fields: [
        :name,
        :date_of_birth,
        :blob
      ]
    }
  end
end
