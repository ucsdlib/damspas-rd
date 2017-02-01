class CollectionShowPresenter < Hyrax::CollectionPresenter
  delegate :spatial, :topic, :created_date, :publisher, to: :solr_document
  delegate :brief_description, :general_note, :location_of_originals, :table_of_contents, to: :solr_document
  delegate :finding_aid, :exhibit, :language, :resource_type, :local_attribution, :extent, to: :solr_document

  def self.terms
    [:total_items, :size, :resource_type, :creator, :contributor, :keyword,
     :rights, :publisher, :date_created, :subject, :language, :identifier,
     :based_near, :related_url,
     :spatial, :topic, :created_date, :finding_aid, :exhibit, :local_attribution, :extent,
     :brief_description, :general_note, :location_of_originals, :table_of_contents
     ]
  end
end
