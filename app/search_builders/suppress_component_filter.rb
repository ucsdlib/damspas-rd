# Injects a search builder filter to hide component documents

module SuppressComponentFilter
  extend ActiveSupport::Concern
  delegate :item, to: :scope

  included do
    self.default_processor_chain += [:suppress_component]
  end

  def suppress_component(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-{!join from=member_ids_ssim to=id}id:*'
  end
end
