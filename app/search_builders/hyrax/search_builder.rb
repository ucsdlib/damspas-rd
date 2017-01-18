# TODO: make this a mixin and generate it into ::SearchBuilder
class Hyrax::SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters
  include ::RolesBaseGatedSearchBuilder

  def show_only_resources_deposited_by_current_user(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] += [
      ActiveFedora::SolrQueryBuilder.construct_query_for_rel(depositor: scope.current_user.user_key)
    ]
  end
end
