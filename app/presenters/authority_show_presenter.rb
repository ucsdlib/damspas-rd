class AuthorityShowPresenter < Hyrax::CollectionPresenter
  # Terms is the list of fields to displayed
  def self.terms
    [:agent_type, :label, :alternate_label, :has_orcid, :exact_match, 
       :close_match, :related_match, :different_from, :note, :point]
    end

  self.terms.each do |term|
    delegate term, to: :solr_document
  end

  # override to lookup the renderer by class name
  def find_renderer_class(name)
    renderer = begin
      super.find_renderer_class(name)
    rescue NameError
      Object.const_get(name)
    end
    raise NameError, "unknown renderer type `#{name}`" if renderer.nil?
    renderer
  end
end
