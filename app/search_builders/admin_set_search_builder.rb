class AdminSetSearchBuilder < Hyrax::AdminSetSearchBuilder
  include ::RolesBaseGatedSearchBuilder
  # This skips the filter added by FilterSuppressed and add_advanced_search
  self.default_processor_chain -= [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :only_active_works]
end
