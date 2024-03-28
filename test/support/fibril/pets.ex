defmodule Fibril.Resource.Pets do
  import Ecto.Query, warn: false

  def resource do
    %{module: Fibril.Pets.Pet, name: "pet", plural: "pets"}
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
