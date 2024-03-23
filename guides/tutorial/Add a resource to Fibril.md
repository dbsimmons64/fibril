## Introduction to Forms

Lets add a form to enable the creation of an `owner`. To do so we must create a module `VetWeb.Fibril.Resource.Owner`. The simplest version of this is:

```
defmodule VetWeb.Fibril.Resource.Owner do
  def resource do
    %{module: Vet.Owners.Owner, name: "owner", plural: "owners"}
  end

  def form() do
    %{
      fields: [:name]
    }
  end

  def table() do
    %{
      fields: [:name]
    }
  end
end
```

As you can see we deine three functions `resource`, `form`, `table`, each of which is explained below.

### resource

The `resource` function defines some general features of the resource such as the module, name and plural of the name.

### form

The `form` function defines which fields are to appear in the create/edit form that Fibril creates. As you'll see later we can also configure how each field is displayed as well as what changeset to use when validating the resource.

### table

The `table` function defines how we display a list of the resources is displayed. 

### A note about the module name

Fibril looks for a specific module format when reading options for a resource. By default it looks for `FibrilWeb.Fibril.Resource` + resource name. The prefix can be changed via a config option.
