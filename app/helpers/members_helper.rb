module MembersHelper
  # @field
  # @values
  # @options
  # Render HTML for members attributes
  def render_member_attribute (field, values, options = {}) 
    renderer = MemberAttributeRenderer.new field, values, options
    renderer.render
  end
end
