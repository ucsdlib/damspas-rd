# Agent is a class in EDM that has possible subclasses
# See:  http://www.europeana.eu/schemas/edm/Agent
class Agent < Authority

  configure type: ::RDF::Vocab::EDM.Agent

  # xsd:anyURI
  property :close_match, predicate: ::RDF::Vocab::SKOS.closeMatch, multiple: true
  property :related_match, predicate: ::RDF::Vocab::SKOS.relatedMatch, multiple: true

  validates :close_match, url: true, allow_blank: true
  validates :related_match, url: true, allow_blank: true

  def to_solr(solr_doc = {})
    super.tap do |solr_doc|
      close_match.each do |obj|
        solr_doc[Solrizer.solr_name('close_match', :stored_searchable)] = authority_label(obj)
      end
      related_match.each do |obj|
        solr_doc[Solrizer.solr_name('related_match', :stored_searchable)] = authority_label(obj)
      end
    end
  end
end
