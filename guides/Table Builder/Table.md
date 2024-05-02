Radiance Table enables the presentation of resource records in a tabular layout. It provides the capability to display associated data and supports inline editing of records. Moreover, it enables pagination and facilitates searching within the records

The layout is defined via a `table/0` function that returns a map defining which fields in a resource to display as well as table related data such as pagination or sort order of columns.




### text  
This workhorse of column types. 

Text accepts the following options:

- badge
- colour
- icon
- description
- text
- html

## Icon Column
An icon column display an icon representing the value of the column.

```
def table() do
    %{
      fields: [,
        %{
          name: :status,
          html_type: :icon,
          options: %{
            ~c"New" => ~c"icon-1",
            ~c"Issued" => ~c"icon-2",
            ~c"Paid" => ~c"icon-3"
          }
        },
      ]
    }
  end
  ```

  Alternatively you can pass a function

  ```
def table() do
    %{
      fields: [,
        %{
          name: :status,
          html_type: :icon,
          options: [&get_icon/1, [:record]]
          
        },
      ]
    }
  end
  ```

![image](images/foo.png) 

