module Hyrax
  module Actors
    class Environment
      # @param [ActiveFedora::Base] curation_concern work to operate on
      # @param [Ability] current_ability the authorizations of the acting user
      # @param [ActionController::Parameters] attributes user provided form attributes
      def initialize(curation_concern, current_ability, attributes)
        @curation_concern = curation_concern
        @current_ability = current_ability

        # convert nested attribute hash to array
        attributes.keys.each do |key|
          next unless key.to_s.ends_with? '_attributes'
          attributes[key] = attributes[key].values if attributes[key].respond_to? :values
        end

        @attributes = attributes.to_h.with_indifferent_access
      end

      attr_reader :curation_concern, :current_ability, :attributes

      # @return [User] the user from the current_ability
      def user
        current_ability.current_user
      end
    end
  end
end
