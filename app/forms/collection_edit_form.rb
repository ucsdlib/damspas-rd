class CollectionEditForm < Hyrax::Forms::CollectionForm
  include SchemaEditFormBehavior
  include ModelAttributeBehavior

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]) if attrs[:title]
    attrs = super(attrs)
    attrs = model_local_attributes(attrs)
    attrs
  end

  def initialize_fields
    super
  end

  def title
    self[:title].first
  end
end
