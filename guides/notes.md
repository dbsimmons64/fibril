Format of a function call should be:

foo: &func/arity, [arguments]

e.g.

```
options: [&get_icon/2, [:record, :field]]
```

* Arguments are extracted automatically by Fibril from `assigns`. 
* Strictly speaking we don't need to specify the argument as we could make all functions arity 1 and simply pass `assigns` as the only argument (as Phoenix does with function components). I've not done this as I think the format is a bit more readable and provides a bit more information - I'll leave it up to others to say whether this works or not.
* The format was inspired by the Ash framework and the ability to inject arguments that Filament provides.
* Depending on the context there should be a number of standard agruments available:

- Record - the current record being processed either as part of a list or form.
- Field - the current field being processed
- User - the current user

* We also need to provide the abilty to store user definable data, and pass it in arguments. Probably achieve this via a `init` type function at the start of index or form.

# Icons
icon: "heroicon-m-envelop",

icon: %{
          icon: 'heroicon-m-envelope',
          icon_position: :after,
          icon_colour: "danger"
        },

