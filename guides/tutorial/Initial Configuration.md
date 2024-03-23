# Configuring the demo application.

Lets create our initial project:

```
mix phx.new vet
```

# Resources

For the demo we'll create three resource; `owners`, `pets`, `treatments`. We will only be creating the schema and migration files as Fibril will take care of the CRUD elements.

```
mix phx.gen.schema Owners.Owner owners name:string

mix phx.gen.schema Pets.Pet pets name:string date_of_birth:date owner_id:references:owners

mix phx.gen.schema Treatments.Treatment treatments description:string notes:text price:integer pet_id:references:pets
```

We'll tweak the various schemas to create `belongs_to` and `has_many` relationships. We've also updated the Pet and Treatment changeset to ensure they have a `owner_id` and `pet_id` respectively. The completed schemas are show below.

### Owners

```
defmodule Vet.Owners.Owner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "owners" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(owner, attrs) do
    owner
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
```

### Pets

```
defmodule Vet.Pets.Pet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pets" do
    field :name, :string
    field :date_of_birth, :date

    belongs_to :owner, Vet.Owners.Owner
    has_many :treatments, Vet.Treatments.Treatment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :date_of_birth, :owner_id])
    |> validate_required([:name, :date_of_birth, :owner_id])
  end
end

```

### Treatments

```
defmodule Vet.Treatments.Treatment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "treatments" do
    field :description, :string
    field :notes, :string
    field :price, :integer

    belongs_to :pet, Vet.Pets.Pet

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(treatment, attrs) do
    treatment
    |> cast(attrs, [:description, :notes, :price, :pet_id])
    |> validate_required([:description, :notes, :price, :pet_id])
  end
end

```
