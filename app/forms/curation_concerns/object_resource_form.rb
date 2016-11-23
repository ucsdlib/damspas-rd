# Generated via
#  `rails generate curation_concerns:work ObjectResource`
module CurationConcerns
  class ObjectResourceForm < Sufia::Forms::WorkForm
    self.model_class = ::ObjectResource
    self.terms += [:resource_type]

  end
end
