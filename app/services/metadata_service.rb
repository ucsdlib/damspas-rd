module MetadataService
  class << self

    # Returns all edm:Agent
    def find_all_agents
      cols = []
      records = ActiveFedora::Base.where('has_model_ssim:Agent')
      records.each do |rec|
        cols << [rec.label.first, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      cols 
    end

    def find_agents (label)
      recs = []
      q = "has_model_ssim:Agent AND label_tesim:\"#{label}\""
      records = ActiveFedora::Base.where(q)
      records.each do |rec|
        recs << [rec.label.first, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      recs 
    end

    # Returns all skos:Concept
    def find_all_subjects
      cols = []
      records = ActiveFedora::Base.where('has_model_ssim:Concept')
      records.each do |rec|
        cols << [rec.label.first, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      cols 
    end

    def local_attribution_list
      values = []
      values << 'Digital Library Development Program, UC San Diego, La Jolla, 92093-0175 (http://libraries.ucsd.edu/about/digital-library/)'
      values << 'Research Data Curation Program, UC San Diego, La Jolla, 92093-0175 (http://libraries.ucsd.edu/services/data-curation/)'
      values << 'Special Collections & Archives, UC San Diego, La Jolla, 92093-0175 (http://libraries.ucsd.edu/collections/sca/)'
      values
    end

    # Returns all ResourceTypes
    def find_all_resource_types
      find_authority_list 'ResourceType'
    end

    # Returns all Languages
    def find_all_languages
      find_authority_list 'Language'
    end

   private
      def find_authority_list(model)
        cols = []
        records = ActiveFedora::Base.where("has_model_ssim:#{model}")
        records = records.sort_by{ |rec| rec.label.first }
        records.each do |rec|
          cols << [rec.label.first, rec.public_uri.first]
        end
        cols 
      end
  end
end
