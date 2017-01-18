class FileSetPresenter < Hyrax::FileSetPresenter
  delegate :creator, to: :solr_document
end
