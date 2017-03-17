# rubocop:disable Metrics/ClassLength
class IdentifierSchema < ActiveTriples::Schema
  property :identifier, predicate: ::RDF::Vocab::DC.identifier, multiple: false
  property :accession, predicate: ::UcsdTerms.accessionId, multiple: false
  property :ark, predicate: ::UcsdTerms.arkId, multiple: false
  property :basket, predicate: ::UcsdTerms.basketId, multiple: false
  property :call_number, predicate: ::RDF::Vocab::MODS.locationShelfLocator, multiple: false
  property :collection_number, predicate: ::UcsdTerms.collectionNumberId, multiple: false
  property :doi, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/identifiers#doi"), multiple: false
  property :edm, predicate: ::UcsdTerms.edmId, multiple: false
  property :event_number, predicate: ::UcsdTerms.eventId, multiple: false
  property :file_name, predicate: ::UcsdTerms.filenameId, multiple: false
  property :igsn, predicate: ::UcsdTerms.igsnId, multiple: false
  property :local, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/identifiers#local"), multiple: false
  property :locus_number, predicate: ::UcsdTerms.locusId, multiple: false
  property :negative, predicate: ::UcsdTerms.negativeId, multiple: false
  property :news_release_number, predicate: ::UcsdTerms.newsReleaseId, multiple: false
  # property :oclc, predicate: ::UcsdTerms.oclcId, multiple: false
  property :registration, predicate: ::UcsdTerms.registrationId, multiple: false
  property :roger, predicate: ::UcsdTerms.rogerId, multiple: false
  property :sample, predicate: ::UcsdTerms.sampleId, multiple: false
  property :sequence, predicate: ::UcsdTerms.sequenceId, multiple: false
  property :shared_shelf, predicate: ::UcsdTerms.sharedShelfId, multiple: false
end
