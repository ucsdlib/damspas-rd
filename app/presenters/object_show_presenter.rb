class ObjectShowPresenter < ::Hyrax::WorkShowPresenter
  # delegate fields from Hyrax::Works::Metadata to solr_document
  delegate :based_near, :related_url, :depositor, :identifier, :resource_type,
           :keyword, :itemtype, :admin_set, to: :solr_document

  delegate :topic, :spatial, :language, to: :solr_document
  delegate :creator, :contributor, :publisher, to: :solr_document
  delegate :created_date, :event_date, to: :solr_document
  delegate :general_note, :physical_description, to: :solr_document

end

