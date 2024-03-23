# Welcome to the Tutorial

The tutorial is desinged to demonstrate the features available in Fibril. It doesn't try and document every single feature or setting but is designed to wet your appetitate as they say. Ok, lets dive in...

Actually, before we do dive in, I'd like to thank the Filament team for their aweseome work that has inspired both Fibril and this tutorial.

**Basic Scenario**

For demonstration purposes we will be modelling a Vet's practise. We'll start with the basics and build up from there.

**Pets**

A vets wouldn't be much use without any animals to treat so we'll start off with a Pet entity.

```
schema "pets" do
    field :name, :string
    field :date_of_birth, :date

    timestamps(type: :utc_datetime)
  end
```

We'll also define a basic `changeset`.

```
def changeset(pet, attrs) do
    pet
    |> cast(attrs, [:name, :date_of_birth])
    |> validate_required([:name, :date_of_birth])
  end
  ```

  **CRUD for Pets**

  The first thing we'd like to do is add the ability to list, create, edit and delete pets. To do this we create a pets configuration file that Fibril can use.

```
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
      fields: [:name, :date_of_birth]
    }
  end
end
```

This is probably the smallest configuration file you can define. It consists of three functions each of which return a configuration map:

`resource` - this provides configuration information for the resource itself. In our case we define the resource schema module `Vets.Pet.Pets` as well as the name of the resource and the plural of the name.

`table` - provides configuration information for the listing of resources.

`form` - configuration information for the create and edit operations to, erm, create and edit a resource.

If you now visit `admin/pets/` you will see a list of all the Pet records as well as the ability to create/edit/delete Pets.

**Labels**

Filament will automatically create a label from the name of a field by capitalising the first letter and replacing any underscores with spaces. So our field, `:date_of_birth`, has a label of `Date of birth`.
