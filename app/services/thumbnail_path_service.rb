class ThumbnailPathService < Hyrax::ThumbnailPathService
  class << self
    # override Hyrax::ThumbnailPathService for metadata-only and culturally-sensitive icon
    # @param [Work, FileSet] object - to get the thumbnail for
    # @return [String] a path to the thumbnail
    def call(object)
      return default_image unless object.thumbnail_id
      # static thumbnails for visibility metadata only and culturally sensitive objects
      visibility_value = VisibilityService.visibility_value(object.rights_override) if object.rights_override.present?
      return icon_path(visibility_value) if get_icon(visibility_value).present?

      thumbnail_file fetch_thumbnail(object)
    end

    # code block extracted from Hyrax::ThumbnailPathService.call(object) to avoid style violation Cyclomaticcomplexity
    def thumbnail_file(thumb)
      return unless thumb
      return call(thumb) unless thumb.is_a?(::FileSet)
      if thumb.audio?
        audio_image
      elsif thumbnail?(thumb)
        thumbnail_path(thumb)
      else
        default_image
      end
    end

    def icon_path(visibility)
      icon = get_icon visibility
      return ActionController::Base.helpers.image_path icon if icon
    end

    def icon_file_path(visibility)
      icon = get_icon visibility
      return Rails.root.join('app', 'assets', 'images', icon).to_s if icon
    end

    def get_icon(visibility)
      case visibility
      when VisibilityService::VISIBILITY_TEXT_VALUE_METADATA_ONLY
        'dc_not_available.jpg'
      when VisibilityService::VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE
        'thumb-restricted.png'
      end
    end
  end
end
