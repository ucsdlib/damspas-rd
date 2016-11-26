# rubocop:disable Metrics/ClassLength
class MarcrelSchema < ActiveTriples::Schema
  property :analyst, predicate: ::RDF::Vocab::MARCRelators.anl, class_name: Agent
  property :artist, predicate: ::RDF::Vocab::MARCRelators.art, class_name: Agent
  property :associatedName, predicate: ::RDF::Vocab::MARCRelators.asn, class_name: Agent
  property :author, predicate: ::RDF::Vocab::MARCRelators.aut, class_name: Agent
  property :collector, predicate: ::RDF::Vocab::MARCRelators.col, class_name: Agent
  property :composer, predicate: ::RDF::Vocab::MARCRelators.cmp, class_name: Agent
  property :conductor, predicate: ::RDF::Vocab::MARCRelators.cnd, class_name: Agent
  # property :coprincipal_investigator, predicate: ::UcsdTerms.coPrincipalInvestigator, class_name: Agent
  property :curator, predicate: ::RDF::Vocab::MARCRelators.cur, class_name: Agent
  property :dancer, predicate: ::RDF::Vocab::MARCRelators.dnc, class_name: Agent
  property :data_manager, predicate: ::RDF::Vocab::MARCRelators.dtm, class_name: Agent
  property :donor, predicate: ::RDF::Vocab::MARCRelators.dnr, class_name: Agent
  property :editor, predicate: ::RDF::Vocab::MARCRelators.edt, class_name: Agent
  # property :field_assistant, predicate: ::UcsdTerms.fieldAssistant, class_name: Agent
  property :former_owner, predicate: ::RDF::Vocab::MARCRelators.fmo, class_name: Agent
  property :funder, predicate: ::RDF::Vocab::MARCRelators.fnd, class_name: Agent
  property :illustrator, predicate: ::RDF::Vocab::MARCRelators.ill, class_name: Agent
  property :interviewee, predicate: ::RDF::Vocab::MARCRelators.ive, class_name: Agent
  property :interviewer, predicate: ::RDF::Vocab::MARCRelators.ivr, class_name: Agent
  # property :laboratory_assistant, predicate: ::UcsdTerms.laboratoryAssistant, class_name: Agent
  property :moderator, predicate: ::RDF::Vocab::MARCRelators.mod, class_name: Agent
  property :organizer, predicate: ::RDF::Vocab::MARCRelators.orm, class_name: Agent
  property :originator, predicate: ::RDF::Vocab::MARCRelators.org, class_name: Agent
  property :performer, predicate: ::RDF::Vocab::MARCRelators.prf, class_name: Agent
  property :photographer, predicate: ::RDF::Vocab::MARCRelators.pht, class_name: Agent
  # property :principal_investigator, predicate: ::UcsdTerms.principalInvestigator, class_name: Agent
  property :producer, predicate: ::RDF::Vocab::MARCRelators.pro, class_name: Agent
  property :researcher, predicate: ::RDF::Vocab::MARCRelators.res, class_name: Agent
  property :research_team_head, predicate: ::RDF::Vocab::MARCRelators.rth, class_name: Agent
  property :research_team_member, predicate: ::RDF::Vocab::MARCRelators.rtm, class_name: Agent
  property :speaker, predicate: ::RDF::Vocab::MARCRelators.spk, class_name: Agent
  property :sponsor, predicate: ::RDF::Vocab::MARCRelators.spn, class_name: Agent
  property :thesis_advisor, predicate: ::RDF::Vocab::MARCRelators.ths, class_name: Agent
  property :transcriber, predicate: ::RDF::Vocab::MARCRelators.trc, class_name: Agent
end
