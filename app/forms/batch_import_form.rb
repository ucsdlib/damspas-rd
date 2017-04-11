class BatchImportForm < Hyrax::Forms::WorkForm
  self.model_class = BatchImportItem
  include HydraEditor::Form::Permissions

  # The WorkForm delegates `#depositor` to `:model`, but `:model` in the
  # BatchImport context is a blank work with a `nil` depositor
  # value. This causes the "Sharing With" widget to display the Depositor as
  # "()". We should be able to reliably pull back the depositor of the new
  # batch of works by asking the form's Ability what its `current_user` is.
  def depositor
    current_ability.current_user
  end

  def self.model_attributes(attrs)
    attrs[:rights] = Array(attrs[:rights]) if attrs[:rights]
    super(attrs)
  end

  # Override of ActiveModel::Model name that allows us to use our
  # custom name class
  def self.model_name
    @_model_name ||= begin
      namespace = parents.detect do |n|
        n.respond_to?(:use_relative_model_naming?) && n.use_relative_model_naming?
      end
      Name.new(model_class, namespace)
    end
  end

  def model_name
    self.class.model_name
  end

  # This is required for routing to the BatchImportController
  def to_model
    self
  end

  # A model name that provides correct routes for the BatchImportController
  # without changing the param key.
  #
  # Example:
  #   name = Name.new(GenericWork)
  #   name.param_key
  #   # => 'generic_work'
  #   name.route_key
  #   # => 'batch_import'
  #
  class Name < ActiveModel::Name
    def initialize(klass, namespace = nil, name = nil)
      super
      @route_key = 'batch_import_index'
    end
  end
end
