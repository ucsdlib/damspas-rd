module SchemaSolrDocumentBehavior
  extend ActiveSupport::Concern

  included do
    terms_all.each do |term|
      next if instance_methods(true).include? term
      send(:define_method, term) do
        self[Solrizer.solr_name(term.to_s)]
      end
    end
  end

  module ClassMethods
    def terms_all
      (GeneralSchema.properties + IdentifierSchema.properties +
       LocalAuthoritySchema.properties + MarcrelSchema.properties)
        .map(&:name) + AuthorityShowPresenter.terms
    end
  end
end
