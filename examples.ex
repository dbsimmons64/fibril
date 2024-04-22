def table() do
  %{
    fields: [
      :name,
      :date_of_birth,
      %{
        name: :type,
        badge: %{
          colours: %{
              "Dog" => "badge-neutral",
              "Cat" => "badge-primary",
              "Rabbit" => "badge-secondary"
            },
          outline: true
        },
        description: %{
          text: "This is a description",
          position: :below
        },

        icon: %{
          name: 'heroicon-m-envelope',
          position: :after,
          colour: "danger"
        },

        datetime: "%b %y",
        since: true,
        money: %{
          currency: "£",
          divide_by: 100
        },
        limit: 50,
        words: 10,
        lineClamp: 2,
        prefix: "https//",
        suffix: ".com",
        wrap: true,
        html: true,
        markdown: true,
        color: 'danger',

        size: :large,
        weight: :bold,
        font_family: :mono,



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
