Fibril is a library that was heavily inspired by Filament in the PHP world. 

This section is basicallly to note down all my ideas so I don't forget them.

Example of a Form
```
%{
      module: Fibril.Pets.Pet,
      fields: [
        :name,
        %{
          name: :type,
          label: "Genus of Animal",
          html_type: :select,
          options: %{
            "dog" => "Dog",
            "cat" => "Cat",
            "rabbit" => "Rabbit"
          }
        },
        :date_of_birth,
        %{
          name: :owner_id,
          queryable: &not_first/0,
          value: :name
        }
      ],
      changeset: :name_changeset
    }
```

A note about `preloads`. 
A the moment you need to ensure that both table and form have the same preloads. This is because when we create a new resource, for example a Pet, we return to the Pet List. The newly created resource is added to the resource stream and the list resource page is displayed. If the list resource page has reference to a association e.g. the Pet Owner, then it will fail unless the Owner resource is loaded.