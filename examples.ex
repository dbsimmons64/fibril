def table() do
  %{
    fields: [
      :name,
      :date_of_birth,

      %{
        name: :type,

        text: %{
          limit: 50,
          words: 10,
          prefix: "https//",
          suffix: ".com",
          html: true,
          colour: "text-red-500"
        },

        description: %{
          text: "This is a description",
          position: :below,
          colour: "text-red-500"
        },

        badge: %{
          colours: %{
              "Dog" => "badge-neutral",
              "Cat" => "badge-primary",
              "Rabbit" => "badge-secondary"
            },
          outline: true
        },


        icon: %{
          name: 'heroicon-m-envelope',
          position: :after,
          colour: "danger",
          size: %{
            height: 5,
            width: 5
          }
        },

        datetime: "%b %y",
        since: true,
        money: %{
          currency: "£",
          divide_by: 100
        },



        font: %{
          size: :large,
          weight: :bold,
          font_family: :mono,
        }

      },
      [:owner, :name],
      %{
        name: :age,
        display_type: :calculated,
        calculation: [&calculate_age/1, :record]
      }
    ],
    pagination: %{
      page_size: 2
    }
  }
end
