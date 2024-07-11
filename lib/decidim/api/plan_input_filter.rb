# frozen_string_literal: true

module Decidim
  module Plans
    class PlanInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasPublishableInputFilter

      graphql_name "PlanFilter"
      description "A type used for filtering plans inside a participatory space.

A typical query would look like:

```
  {
    participatoryProcesses {
      components {
        ...on Plans {
          plans(filter:{ publishedBefore: \"2020-01-01\", state: [\"accepted\", \"evaluating\"] }) {
            id
          }
        }
      }
    }
  }
```
"

      argument(
        :state,
        type: [GraphQL::Types::String],
        description:
          <<~DESC,
            Filters the plans of the specified types. Allowed values are "open",
            "accepted", "evaluating", "rejected" and "withdrawn". By default,
            the withdrawn plans will not be included.
          DESC
        required: false,
        prepare: lambda { |states, _ctx|
                   valid = %w(open accepted evaluating rejected withdrawn) & states
                   valid << nil if valid.include?("open")
                   { state: valid } if valid.any?
                 }
      )
    end
  end
end
