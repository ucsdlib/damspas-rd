# UcsdAgent is a subclass of EDM Agent (http://www.europeana.eu/schemas/edm/Agent)
class UcsdAgent < Agent

  configure type: ::UcsdTerms.UcsdAgent

  property :agent_type, predicate: ::UcsdTerms.agent_type, multiple: false
  property :orcid, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/identifiers#orcid"), multiple: false

  # xsd:anyURI
  property :close_match, predicate: ::RDF::Vocab::SKOS.closeMatch, multiple: true
  property :related_match, predicate: ::RDF::Vocab::SKOS.relatedMatch, multiple: true
  property :different_from, predicate: ::RDF::URI.new("https://www.w3.org/TR/owl-ref/differentFrom"), multiple: true

  validates :close_match, url: true, allow_blank: true
  validates :related_match, url: true, allow_blank: true
  validates :different_from, url: true, allow_blank: true

  validates :agent_type, presence: { message: 'Agent must have a type.' }

  def to_solr(solr_doc = {})
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('agent_type', :stored_searchable)] = agent_type
      solr_doc[Solrizer.solr_name('orcid', :stored_searchable)] = orcid

      index_authorities solr_doc, :close_match, close_match
      index_authorities solr_doc, :related_match, related_match
      index_authorities solr_doc, :different_from, different_from
    end
  end
end
