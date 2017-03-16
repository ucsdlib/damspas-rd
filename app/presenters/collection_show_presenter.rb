class CollectionShowPresenter < Hyrax::CollectionPresenter
  delegate :spatial, :topic, :created_date, :publisher, to: :solr_document
  delegate :brief_description, :general_note, :location_of_originals, :table_of_contents, to: :solr_document
  delegate :finding_aid, :exhibit, :language, :resource_type, :local_attribution, :extent, to: :solr_document

  IdentifierSchema.properties.each do |prop|
    term = prop.name.to_sym
    delegate term, to: :solr_document
  end

  def self.terms
    [:total_items, :size, :resource_type, :creator, :contributor, :keyword,
     :rights, :publisher, :date_created, :subject, :language, :identifier,
     :based_near, :related_url,
     :spatial, :topic, :created_date, :finding_aid, :exhibit, :local_attribution, :extent,
     :brief_description, :general_note, :location_of_originals, :table_of_contents
    ].tap do |terms|
      IdentifierSchema.properties.each do |prop|
        term = prop.name.to_sym
        terms << term
      end
    end
  end
end
