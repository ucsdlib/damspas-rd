# Generated via
#  `rails generate hyrax:work ObjectResource`
module Hyrax
  class ObjectResourceForm < Hyrax::Forms::WorkForm
    include SchemaEditFormBehavior
    include ModelAttributeBehavior

    self.model_class = ::ObjectResource

    self.required_fields = [:title, :copyright_status]

    def self.model_attributes(attrs)
      attrs[:copyright_status] = Array(attrs[:copyright_status]) if attrs[:copyright_status]
      attrs[:copyright_jurisdiction] = Array(attrs[:copyright_jurisdiction]) if attrs[:copyright_jurisdiction]

      attrs = super(attrs)
      model_local_attributes(attrs)
      attrs
    end
  end
end
