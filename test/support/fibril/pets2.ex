defmodule Fibril.Resource.Pets2 do
  import Ecto.Query, warn: false

  def resource do
    %{module: Fibril.Pets.Pet, name: "pet", plural: "pets"}
  end

  def table() do
    %{
      fields: [:date_of_birth]
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
