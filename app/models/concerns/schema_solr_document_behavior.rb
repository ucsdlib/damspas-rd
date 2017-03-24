module SchemaSolrDocumentBehavior
  extend ActiveSupport::Concern

  included do
    self.terms_all.each do |term|
      next if self.instance_methods(true).include? term
      self.send(:define_method, term) do
        self[Solrizer.solr_name(term.to_s)]
      end
    end
  end

  module ClassMethods
    def terms_all
      (GeneralSchema.properties + IdentifierSchema.properties + LocalAuthoritySchema.properties + MarcrelSchema.properties)
        .map { |prop| prop.name } + AuthorityShowPresenter.terms
    end
  end
end
