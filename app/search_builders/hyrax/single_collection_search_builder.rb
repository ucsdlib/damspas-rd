module Hyrax
  class SingleCollectionSearchBuilder < ::SearchBuilder
    include SingleResult
    include ::RolesBaseGatedSearchBuilder
  end
end
