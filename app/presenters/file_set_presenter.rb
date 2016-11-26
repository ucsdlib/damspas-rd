class FileSetPresenter < Sufia::FileSetPresenter
  delegate :creator, to: :solr_document
end
