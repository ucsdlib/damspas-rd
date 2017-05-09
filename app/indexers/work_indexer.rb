  class WorkIndexer < Hyrax::WorkIndexer
    include IndexesAttributes
    self.thumbnail_path_service = ::ThumbnailPathService
  end