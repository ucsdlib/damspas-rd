# Generated via
#  `rails generate hyrax:work ObjectResource`
module Hyrax
  class ObjectResourceForm < Hyrax::Forms::WorkForm
    include SchemaEditFormBehavior
    include ModelAttributeBehavior

    self.model_class = ::ObjectResource

    def self.model_attributes(attrs)
      attrs = super(attrs)
      model_local_attributes(attrs)
      attrs
    end
  end
end
