module MetadataService
  class << self
    def local_attribution_list
      find_authority_list('local_attributions').map(&:first)
    end

    # Returns all ResourceTypes
    def find_all_resource_types
      find_authority_list('resource_types')
    end

    # Returns all RelatedResource types
    def find_all_related_resource_types
      find_authority_list('related_resource_types')
    end

    # Returns all Languages
    def find_all_languages
      find_authority_list('languages')
    end

    # Returns all CopyrightStatus
    def find_all_copyright_status
      find_authority_list('copyright_status')
    end

    # Returns all CountryCodes
    def find_all_country_codes
      find_authority_list('country_codes')
    end

    private

      def find_authority_list(model)
        cols = []
        Qa::Authorities::Local.subauthority_for(model).all.each do |rec|
          cols << [rec['label'], rec['id']]
        end
        cols
      end
  end
end
