require 'rdf'
class UcsdTerms < RDF::StrictVocabulary('http://library.ucsd.edu/ontology/dams5.0#')
  term :coPrincipalInvestigator, label: "Co-Principal Investigator".freeze, type: 'rdf:Property'.freeze
  term :fieldAssistant, label: "Field Assistant".freeze, type: 'rdf:Property'.freeze
  term :laboratoryAssistant, label: "Laboratory Assistant".freeze, type: 'rdf:Property'.freeze
  term :principalInvestigator, label: "Principal Investigator".freeze, type: 'rdf:Property'.freeze
  term :eventDate, label: 'Event Date'.freeze, type: 'rdf:Property'.freeze
  term :collectionDate, label: "Collection Date".freeze, type: 'rdf:Property'.freeze
  term :biography, label: "Biography".freeze, type: 'rdf:Property'.freeze
  term :briefDescription, label: "Brief Description".freeze, type: 'rdf:Property'.freeze
  term :finds, label: "Finds".freeze, type: 'rdf:Property'.freeze
  term :funding, label: "Funding".freeze, type: 'rdf:Property'.freeze
  term :inscription, label: "inscription".freeze, type: 'rdf:Property'.freeze
  term :limits, label: "limits".freeze, type: 'rdf:Property'.freeze
  term :localAttribution, label: "localAttribution".freeze, type: 'rdf:Property'.freeze
  term :locationOfOriginals, label: "locationOfOriginals".freeze, type: 'rdf:Property'.freeze
  term :materialDetails, label: "materialDetails".freeze, type: 'rdf:Property'.freeze
  term :methods, label: "methods".freeze, type: 'rdf:Property'.freeze
  term :publication, label: "publication".freeze, type: 'rdf:Property'.freeze
  term :physicalDescription, label: "physicalDescription".freeze, type: 'rdf:Property'.freeze
  term :relationshipToOtherLoci, label: "relationshipToOtherLoci".freeze, type: 'rdf:Property'.freeze
  term :storageMethod, label: "storageMethod".freeze, type: 'rdf:Property'.freeze
  term :technicalDetails, label: "technicalDetails".freeze, type: 'rdf:Property'.freeze
  term :workTitle, label: "workTitle".freeze, type: 'rdf:Property'.freeze
  term :waterDepth, label: "waterDepth".freeze, type: 'rdf:Property'.freeze
  term :area, label: "area".freeze, type: 'rdf:Property'.freeze
  term :depiction, label: "depiction".freeze, type: 'rdf:Property'.freeze
  term :exhibit, label: "exhibit".freeze, type: 'rdf:Property'.freeze
  term :findingAid, label: "findingAid".freeze, type: 'rdf:Property'.freeze
  term :locus, label: "locus".freeze, type: 'rdf:Property'.freeze
  term :newsRelease, label: "newsRelease".freeze, type: 'rdf:Property'.freeze
  term :stratum, label: "stratum".freeze, type: 'rdf:Property'.freeze
  term :anatomy, label: "anatomy".freeze, type: 'rdf:Property'.freeze
  term :series, label: "series".freeze, type: 'rdf:Property'.freeze
  term :vesselName, label: "vesselName".freeze, type: 'rdf:Property'.freeze
end
