module SchemaSolrDocumentBehavior
  extend ActiveSupport::Concern

  included do
    (GeneralSchema.properties + IdentifierSchema.properties + LocalAuthoritySchema.properties + MarcrelSchema.properties).each do |prop|
      term = prop.name.to_sym
      next if self.instance_methods(true).include? term
      self.send(:define_method, term) do
        self[Solrizer.solr_name(term.to_s)]
      end
    end
  end
end
