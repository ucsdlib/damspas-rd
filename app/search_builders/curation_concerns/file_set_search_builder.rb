module CurationConcerns
  class FileSetSearchBuilder < ::SearchBuilder
    include CurationConcerns::SingleResult
    include ::RolesBaseGatedSearchBuilder

    # This overrides the models in FilterByType
    def models
      [::FileSet]
    end
  end
end
