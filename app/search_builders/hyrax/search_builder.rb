# TODO: make this a mixin and generate it into ::SearchBuilder
class Hyrax::SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters
  include ::RolesBaseGatedSearchBuilder
  include ::SuppressDiscoveryFilter

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  def show_only_resources_deposited_by_current_user(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [
      ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: scope.current_user.user_key)
    ]
  end
end
