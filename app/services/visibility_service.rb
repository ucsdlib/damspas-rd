# Class to convert customized visibility values
class VisibilityService
  VISIBILITY_TEXT_VALUE_SUPPRESS_DISCOVERY = 'suppress_discovery'.freeze
  VISIBILITY_TEXT_VALUE_METADATA_ONLY = 'metadata_only'.freeze
  VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE = 'culturally_sensitive'.freeze

  # convert the visibility term to visibility text value
  # @param [String] term
  def self.visibility_value(term)
    case term
    when 'campus'
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    else
      term.gsub('-', '_')
    end
  end

  # convert the visibility value to rights override term
  # @param [String] value
  def self.rights_override_value(visibility)
    visibility.gsub('_', '-')
  end
end
