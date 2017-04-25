module SchemaPresenterBehavior
  extend ActiveSupport::Concern

  included do
    self.all_properties.each do |prop|
      term = prop.name.to_sym
      delegate term, to: :solr_document
    end
  end

  module ClassMethods
    def all_properties
      GeneralSchema.properties + IdentifierSchema.properties + LocalAuthoritySchema.properties + MarcrelSchema.properties
    end

    def terms
      [:total_items, :size, :resource_type, :creator, :contributor, :keyword,
       :license, :publisher, :date_created, :subject, :language, :identifier,
       :based_near, :related_url].tap do |terms|
        all_properties.each do |prop|
          term = prop.name.to_sym
          terms << term if !terms.include? term
        end
      end
    end
  end
end
