Hopefully you'll agree that adding an `owner` resource was pretty straight forward. So what about adding `pets`? The most basic configuration for `pets` would be:

```
defmodule VetWeb.Fibril.Resource.Pet do
  def resource do
    %{module: Vet.Pets.Pet, name: "pet", plural: "pets"}
  end

  def form() do
    %{
      fields: [:name, :date_of_birth, %{name: :owner_id, value: :name}]
    }
  end

  def table() do
    %{
      fields: [:name, 
      [:owner, :name]
     ]
    }
  end
end
```

A couple of points of note.

In the `form` we provide a map rather than am atom for the `:owner_id` field. Fibril knows that a `pet` belongs to an `owner` and therefore provides a select pre-populated with the names of all the owners - the `value: :name` entry in the map. 

In the `table` we want to display the name of the `owner`. To do this we provide a path that Fibril can use to get to the `owner` `name`.

The above works but when we display the list of pets we get a column for the pets name labelled 'name' and a column for the owners name also labelled 'name'. It would make sense to differentiate between the two `name` columns. Lets update the table function to do this.

```
def table() do
    %{
      fields: [:name, 
      %{
        name: [:owner, :name],
        label: "Owners name"
      }
     ]
    }
  end
```