module AuthoritiesService
  class << self

    # Returns all ucsd:Agent
    def find_all_agents
      cols = []
      records = ActiveFedora::Base.where('has_model_ssim:UcsdAgent')
      records.each do |rec|
        cols << [rec.label, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      cols 
    end

    def find_agents (label, alt_label='')
      recs = []
      q = "has_model_ssim:UcsdAgent AND label_tesim:\"#{label}\""
      records = ActiveFedora::Base.where(q)
      records.each do |rec|
        recs << rec if is_authority_matched rec, label, alt_label
      end
      recs 
    end

    # Returns all skos:Concept
    def find_all_subjects
      cols = []
      records = ActiveFedora::Base.where('has_model_ssim:Concept')
      records.each do |rec|
        cols << [rec.label, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      cols 
    end

    # Returns all edm:Place
    def find_all_places
      cols = []
      records = ActiveFedora::Base.where('has_model_ssim:Place')
      records.each do |rec|
        cols << [rec.label, RDF::URI(ActiveFedora::Base.id_to_uri(rec.id))]
      end
      cols 
    end

    # find or create authority record
    def find_or_create (model, label, alt_label='', agent_type=nil)
      mod = Object.const_get(model)
      records = ActiveFedora::Base.where("has_model_ssim:#{model} AND label_tesim:\"#{label}\"").collect { |rec| rec  if is_authority_matched rec, label, alt_label }
      return records.first if records.count > 0
      return mod.create(label: label, alternate_label: alt_label) if agent_type.blank? && model != 'UcsdAgent'
      # agent_type required, default to Person
      agent_type ||= 'Person'
      mod.create(label: label, alternate_label: alt_label, agent_type: agent_type)
    end

    # logic exact matching for label and alternate_label
    def is_authority_matched(auth, label, alt_label)
      auth.label == label && (alt_label.blank? || alt_label == auth.alternate_label)
    end
  end
end
