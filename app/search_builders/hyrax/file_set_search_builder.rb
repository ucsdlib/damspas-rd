module Hyrax
  class FileSetSearchBuilder < ::SearchBuilder
    include Hyrax::SingleResult
    include ::RolesBaseGatedSearchBuilder

    # This overrides the models in FilterByType
    def models
      [::FileSet]
    end
  end
end
