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
          plans(filter:{ publishedBefore: \"2020-01-01\" }) {
            id
          }
        }
      }
    }
  }
```
"
    end
  end
end
