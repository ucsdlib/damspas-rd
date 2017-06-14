# rubocop:disable Metrics/LineLength
class GeneralSchema < ActiveTriples::Schema
  property :description, predicate: ::RDF::Vocab::DC11.description
  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :table_of_contents, predicate: ::RDF::Vocab::DC.tableOfContents
  property :arrangement, predicate: ::RDF::Vocab::Bibframe.materialArrangement
  property :biography, predicate: ::UcsdTerms.biography
  property :brief_description, predicate: ::UcsdTerms.briefDescription, multiple: false
  property :credits, predicate: ::RDF::Vocab::Bibframe.creditsNote
  property :custodial_history, predicate: ::RDF::Vocab::Bibframe.custodialHistory
  property :edition, predicate: ::RDF::Vocab::Bibframe.edition
  property :finds, predicate: ::UcsdTerms.finds
  property :funding, predicate: ::UcsdTerms.funding
  property :note, predicate: ::RDF::Vocab::DC.abstract
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
  # property :relation, predicate: ::RDF::Vocab::DC11.relation
  property :rights_note, predicate: ::RDF::Vocab::DC11.rights
  property :title, predicate: ::RDF::Vocab::DC.title
  property :alternative, predicate: ::RDF::Vocab::DC.alternative
  property :part_name, predicate: ::RDF::Vocab::MODS.partName
  property :part_number, predicate: ::RDF::Vocab::MODS.partNumber
  property :subtitle, predicate: ::RDF::URI.new("http://www.loc.gov/mods/rdf/v1#subTitle")
  property :work_featured, predicate: ::UcsdTerms.workFeatured
  property :venue, predicate: ::UcsdTerms.venue
  # property :rights_statement, predicate: ::RDF::Vocab::EDM.rights

  # Literal with CVs: string (controlled ISO ALPHA-2 Code)
  property :copyright_jurisdiction, predicate: ::RDF::Vocab::PREMIS.hasCopyrightJurisdiction

  # xsd:anyURI with CVs
  property :rights_override, predicate: VisibilityService::PREDICATE_RIGHTS_OVERRIDE, multiple: false
  property :copyright_status, predicate: ::RDF::Vocab::PREMIS.hasCopyrightStatus
  property :license, predicate: ::RDF::Vocab::DC.rights

  # predicates that need discussions?
  # ? property :location, predicate: ::RDF::Vocab::DC.spatial	dpla:Place -- deleted
  # ? property :isReplacedBy		dpla:isReplacedBy                          -- Won't use
  # ? property :replaces		dpla:replaces                                  -- Won't use
  # property :genre, predicate: ::RDF::Vocab::EDM.hasType, class_name: Concept -- deleted

  # Fields to auto display. Ignore those for custom display logic and those admin data like (workflow note), title, description, :created_date, :date_created (default), etc.
  def self.display_fields
    ObjectResource.properties.values.map(&:term) - [:title, :topic, :creator, :contributor, :publisher, :created_date, :brief_description, :description, :identifier, :rights, :date_modified, :date_uploaded, :date_created, :depositor, :keyword, :head, :tail]
  end
end
