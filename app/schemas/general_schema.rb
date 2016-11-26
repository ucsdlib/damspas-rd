# rubocop:disable Metrics/ClassLength
class GeneralSchema < ActiveTriples::Schema

  property :description, predicate: ::RDF::Vocab::DC.description
  property :preferred_citation, predicate: ::RDF::Vocab::Bibframe.preferredCitation
  property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents
  property :arrangement, predicate: ::RDF::Vocab::Bibframe.materialArrangement
  property :biography, predicate: ::UcsdTerms.biography
  property :brief_description, predicate: ::UcsdTerms.briefDescription, multiple: false
  property :credits, predicate: ::RDF::Vocab::Bibframe.creditsNote
  property :custodial_history, predicate: ::RDF::Vocab::Bibframe.custodialHistory
  property :edition, predicate: ::RDF::Vocab::Bibframe.edition
  property :finds, predicate: ::UcsdTerms.finds
  property :funding, predicate: ::UcsdTerms.funding
  property :general_note, predicate: ::RDF::Vocab::DC.abstract
  property :inscription, predicate: ::UcsdTerms.inscription
  property :limits, predicate: ::UcsdTerms.limits
  property :local_attribution, predicate: ::UcsdTerms.localAttribution
  property :location_of_originals, predicate: ::UcsdTerms.locationOfOriginals, multiple: false
  property :material_details, predicate: ::UcsdTerms.materialDetails
  property :methodz, predicate: ::UcsdTerms.methods
  property :physical_description, predicate: ::UcsdTerms.physicalDescription
  property :publication, predicate: ::UcsdTerms.publication
  property :relationship_to_otherLoci, predicate: ::UcsdTerms.relationshipToOtherLoci
  property :scope_and_content, predicate: ::RDF::Vocab::Bibframe.contentsNote
  property :statement_of_responsibility, predicate: ::RDF::Vocab::Bibframe.responsibilityStatement
  property :storage_method, predicate: ::UcsdTerms.storageMethod
  property :technical_details, predicate: ::UcsdTerms.technicalDetails
  property :work_title, predicate: ::UcsdTerms.workTitle
  property :water_depth, predicate: ::UcsdTerms.waterDepth
  property :format, predicate: ::RDF::Vocab::DC11.format
  property :extent, predicate: ::RDF::Vocab::DC.extent
  property :relation, predicate: ::RDF::Vocab::DC11.relation
  property :rights_note, predicate: ::RDF::Vocab::DC11.rights
  property :copyright_jurisiction, predicate: ::RDF::Vocab::PREMIS.hasCopyrightJurisdiction
  property :title, predicate: ::RDF::Vocab::DC.title
  property :alternative, predicate: ::RDF::Vocab::DC.alternative
  property :part_name, predicate: ::RDF::Vocab::MODS.partName
  property :part_number, predicate: ::RDF::Vocab::MODS.partNumber
  property :subtitle, predicate: ::RDF::URI.new("http://www.loc.gov/mods/rdf/v1#subTitle")


  # predicates that required xsd:anyURI value
  property :identifier, predicate: ::RDF::Vocab::DC.identifier, multiple: false
  property :area, predicate: ::UcsdTerms.area
  property :depiction, predicate: ::UcsdTerms.depiction
  property :exhibit, predicate: ::UcsdTerms.exhibit, multiple: false
  property :finding_aid, predicate: ::UcsdTerms.findingAid, multiple: false
  property :locus, predicate: ::UcsdTerms.locus
  property :news_release, predicate: ::UcsdTerms.newsRelease
  property :stratum, predicate: ::UcsdTerms.stratum
  property :rights, predicate: ::RDF::Vocab::EDM.rights

  # xsd:anyURI with CVs
  property :rightsOverride, predicate: ::RDF::URI.new("http://pcdm.org/2015/06/03/rights#rightsOverride")
  property :copyright_status, predicate: ::RDF::Vocab::PREMIS.hasCopyrightStatus

  # predicates that need discussions?
  #? property :location, predicate: ::RDF::Vocab::DC.spatial	dpla:Place -- deleted
  #? property :isReplacedBy		dpla:isReplacedBy                          -- Won't use
  #? property :replaces		dpla:replaces                                  -- Won't use
  # property :genre, predicate: ::RDF::Vocab::EDM.hasType, class_name: Concept -- deleted

  # Fields to auto display. Ignore those for custom display logic and those admin data like (workflow note), title, description, :created_date, :date_created (default), etc.
  def self.display_fields
    ObjectResource.properties.values.map(&:term) - [:title, :topic, :creator, :contributor, :publisher, :created_date, :brief_description, :description, :identifier, :date_modified, :date_uploaded, :date_created, :depositor, :keyword, :head, :tail]
  end
end
