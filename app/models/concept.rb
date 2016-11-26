# Concept is a class of skos:Concept
# See:  http://www.w3.org/2004/02/skos/core#
class Concept < Authority
   extend ActiveTriples::Configurable

  configure type: ::RDF::Vocab::SKOS.Concept

  # xsd:anyURI
  property :close_match, predicate: ::RDF::Vocab::SKOS.closeMatch, multiple: true
  property :related_match, predicate: ::RDF::Vocab::SKOS.relatedMatch, multiple: true
  property :note, predicate: ::RDF::Vocab::SKOS.note, multiple: true

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
      note.each do |val|
        solr_doc[Solrizer.solr_name('note', :stored_searchable)] = val
      end
    end
  end
end

