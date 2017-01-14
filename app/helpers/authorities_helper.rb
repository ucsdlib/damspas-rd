module AuthoritiesHelper
  # @field
  # @values
  # @options
  # Render HTML for attributes
  def render_attribute (field, values, options = {})
    renderer = ::Hyrax::Renderers::AttributeRenderer.new field, values, options
    renderer.render
  end

  # @field
  # @values
  # @options
  # Render HTML for authority attributes
  def render_authority_attribute (field, values, options = {})
    renderer = AuthorityAttributeRenderer.new field, values, options
    renderer.render
  end
end
