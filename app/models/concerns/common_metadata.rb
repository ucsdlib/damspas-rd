require 'vocab/ucsd_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do

    # GeneralSchema
    apply_schema GeneralSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    # xsd:URI with CVs
    property :resource_type, predicate: ::RDF::Vocab::DC.type, class_name: ResourceType
    property :language, predicate: ::RDF::Vocab::DC.language, class_name: Language

    # creator: edm:Agent
    property :creator, predicate: ::RDF::Vocab::DC.creator, class_name: Agent
    property :contributor, predicate: RDF::Vocab::DC.contributor, class_name: Agent
    property :publisher, predicate: ::RDF::Vocab::DC.publisher, class_name: Agent 

    property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder, class_name: Agent
    property :name, predicate: ::RDF::Vocab::FOAF.name, class_name: Agent
    property :vessel, predicate: ::UcsdTerms.vesselName, class_name: Agent

    # Group to MARC Relators? 
    property :coprincipal_investigator, predicate: ::UcsdTerms.coPrincipalInvestigator, class_name: Agent
    property :field_assistant, predicate: ::UcsdTerms.fieldAssistant, class_name: Agent
    property :laboratory_assistant, predicate: ::UcsdTerms.laboratoryAssistant, class_name: Agent
    property :principal_investigator, predicate: ::UcsdTerms.principalInvestigator, class_name: Agent
    property :cruise, predicate: ::RDF::URI.new("http://schema.geolink.org/hasCruise"), class_name: Agent

    # topic: skos:Concept
    property :topic, predicate: ::RDF::Vocab::DC.subject, class_name: Concept

    property :anatomy, predicate: ::UcsdTerms.anatomy, class_name: Concept
    property :genre_form, predicate: ::RDF::Vocab::Bibframe.genre, class_name: Concept
    property :lithology, predicate: ::RDF::Vocab::DWC.lithostratigraphicTerms, class_name: Concept
    property :scientific_name, predicate: ::RDF::Vocab::DWC.scientificName, class_name: Concept
    property :series, predicate: ::UcsdTerms.series, class_name: Concept
    property :cultural_context, predicate: ::RDF::URI.new("http://purl.org/vra/culturalContext"), class_name: Concept
    

    # spatial: edm:Place
    property :spatial, predicate: ::RDF::Vocab::DC.spatial, class_name: Place

    # date: edm:TimeSpan
    property :date, predicate: RDF::Vocab::DC11.date, class_name: TimeSpan
    property :created_date, predicate: RDF::Vocab::DC.created, class_name: TimeSpan
    property :event_date, predicate: UcsdTerms.eventDate, class_name: TimeSpan
    property :collection_date, predicate: UcsdTerms.collectionDate, class_name: TimeSpan
    property :copyright_date, predicate: RDF::Vocab::DC.dateCopyrighted, class_name: TimeSpan
    property :issue_date, predicate: RDF::Vocab::DC.issued, class_name: TimeSpan

    # temporal: edm:TimeSpan
    property :temporal, predicate: RDF::Vocab::DC.temporal, class_name: TimeSpan
    property :rightsOverrideExpiration, predicate: ::RDF::URI.new("http://pcdm.org/2015/06/03/rights#rightsOverrideExpiration"), class_name: TimeSpan

  end
end
