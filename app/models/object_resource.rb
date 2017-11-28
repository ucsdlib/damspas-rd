# Generated via
#  `rails generate hyrax:work ObjectResource`
class ObjectResource < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::RightsOverrideBehavior
  include ::CommonMetadata
  include NestedAttributes

  self.human_readable_type = 'Object'
  self.indexer = ::WorkIndexer

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :language, url: { message: 'Invalid label for language field!' }, allow_blank: true

  def visibility
    return VisibilityService.visibility_value(rights_override) if rights_override.present?
    super
  end

  def visibility=(value)
    case value
    when VisibilityService::VISIBILITY_TEXT_VALUE_SUPPRESS_DISCOVERY,
           VisibilityService::VISIBILITY_TEXT_VALUE_METADATA_ONLY,
           VisibilityService::VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE
      self.rights_override = VisibilityService.rights_override_value(value)
      value = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    else
      self.rights_override = nil
    end
    super
  end

  def visibility_changed?
    return rights_override_change? if rights_override.present? || file_sets.first.rights_override.present?
    super
  end

  def permissions_changed?
    return rights_override_change? if rights_override.present? || file_sets.first.rights_override.present?
    super
  end

  def rights_override_change?
    return true if rights_override != file_sets.first.rights_override
    false
  end
end
