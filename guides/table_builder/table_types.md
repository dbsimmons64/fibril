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

