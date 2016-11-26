# Place is a class in EDM that has possible subclasses of
# See:  http://www.europeana.eu/schemas/edm/Place
class Place  < Authority
  configure type: ::RDF::Vocab::EDM.Place

  property :note, predicate: ::RDF::Vocab::SKOS.note
  property :point, predicate: ::RDF::URI.new('http://www.w3.org/2003/01/geo/wgs84_pos#lat_long'), multiple: false

  def to_solr(solr_doc = {})
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('note', :stored_searchable)] = note if !note.blank?
      solr_doc[Solrizer.solr_name('point', :stored_searchable)] = point if !point.blank?
    end
  end
end
