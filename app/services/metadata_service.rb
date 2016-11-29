module MetadataService
  class << self
    def local_attribution_list
      local_attributions = []
      find_authority_list('local_attributions').map { |e| e.first }
    end

    # Returns all ResourceTypes
    def find_all_resource_types
      find_authority_list('resource_types')
    end

    # Returns all Languages
    def find_all_languages
      find_authority_list('languages')
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
