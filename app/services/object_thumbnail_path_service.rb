  class ObjectThumbnailPathService < Sufia::WorkThumbnailPathService
    class << self
        # @return the network path to the thumbnail
        # @param [FileSet] thumbnail the object that is the thumbnail
        def thumbnail_path(thumbnail)
          Rails.application.routes.url_helpers.download_path(thumbnail.id,
                                                             file: 'thumbnail')
        end

        # @return true if there a thumbnail file for this object, otherwise false
        # @param [FileSet] thumbnail the object that is the thumbnail
        def thumbnail?(thumb)
          !thumb.thumbnail.nil?
        end
    end
  end
