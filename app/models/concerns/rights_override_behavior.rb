module RightsOverrideBehavior
  extend ActiveSupport::Concern

  included do
    property :rights_override, predicate: VisibilityService::PREDICATE_RIGHTS_OVERRIDE, multiple: false do |index|
      index.as :stored_searchable
    end
  end

  def visibility
    return VisibilityService.visibility_value(rights_override) if rights_override.present?
    super
  end
end
