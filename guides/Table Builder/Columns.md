### Columns
As a minimum the table function must return a map with a key of `fields`. The value of `fields` is a list containing atoms or maps that represent the fields to be displayed in the table. The simplest table map would return a list of atoms.

```
def table() do
  %{
    fields: [:name, :date_of_birth, :email]
  }
end
```

A map can be used instead of an atom enabling further options for the display of the field.

```
def table() do
  %{
    fields: [
      :name, 
      :date_of_birth, 
      %{
        name: :email,
        icon: %{
          name: "hero-envelope",
          position: :before
        }
      }
    ]
  }
end
```

As you can see the list of fields can contain both atoms and maps.

### Column Types
Radiance Table supports the following display types for a column, each of which is described in further detail below.

- text
- textarea
- input
- decimal
- integer
- date
- icon
- boolean

The display type is defined by the `display_type` key.

>#### Default Table Column Types {: .info} 
>
> Radiance will determine an appropriate display type if none is specified.

### Column Options
Each column type accepts a set of options to further define how the column should look. In general each type will accept
a range of value types. For example, the icon type will accept:

- string

```
  icon: ""hero-envelope"
```

- map

```
  icon: %{
    name: "hero-envelope",
    position: :before
  }
```

- function 

```
  icon: [&set_icon/1, :record]
```

### Passing a function as an option value
The majority of options for a table will accept a function in the form of a list where the first item is a function and subsequent items, if any, refer to values
found in the assign. For example:

```
  icon: [&set_icon/1, :record]
```

This will call the function `set_icon` passing the current value stored under `assigns.record`. The `set_icon` function might look something like:

```
def set_icon(record) do
  if record.mood == "Happy" do
    "hero-face-smile"
  else
    "hero-face-frown"
  end
end
```

## Text Column

### Overview

Text columns display simple text from your database:

```
def table() do
    %{
      fields: [
        %{
          name: :title,
          column_type: :text
        }
      ]
    }
end
```

### Text Options
With the text column type you can:

- display your data as a badge
- set the text colour
- add an icon
- add a description
- limit the text length
- limit the word count
- add a prefix or a suffix
- display content as html

```
def table() do
    %{
      fields: [
        %{
            name: :status,
            column_type: :text,
            badge: %{
                colours: %{
                    "Dog" => "badge-neutral",
                    "Cat" => "badge-primary",
                    "Rabbit" => "badge-secondary"
            
                }
            }
        }
      ]
    }
end
```

## Text Area Column

### Overview

Text Area column allows the display of multi-line text.

### Text Options
With the text column type you can:

- set the text colour
- add a description
- limit the text length
- limit the word count
- limit the number of lines displayed 
- display content as html


