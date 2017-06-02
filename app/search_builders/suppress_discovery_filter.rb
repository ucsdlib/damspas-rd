# Injects a search builder filter to hide documents marked as suppress_discovery
# frozen_string_literal: true

module SuppressDiscoveryFilter
  extend ActiveSupport::Concern

  included do
    self.default_processor_chain += [:suppress_discovery]
  end

  def suppress_discovery(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppress_discovery_bsi:true'
  end
end
