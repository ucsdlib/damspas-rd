class ThumbnailPathService < Hyrax::ThumbnailPathService
  class << self
    # override Hyrax::ThumbnailPathService for metadata-only and culturally-sensitive icon
    # @param [Work, FileSet] object - to get the thumbnail for
    # @return [String] a path to the thumbnail
    def call(object)
      return default_image unless object.thumbnail_id
      # static thumbnails for visibility metadata only and culturally sensitive objects
      if !object.rights_override.blank?
        thumbnail_path = icon_path(VisibilityService.visibility_value(object.rights_override))
        return thumbnail_path if thumbnail_path
      end

      thumb = fetch_thumbnail(object)
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
      return Rails.root.join("app", "assets", "images", icon).to_s if icon
    end

    def get_icon(visibility)
      case visibility
      when VisibilityService::VISIBILITY_TEXT_VALUE_METADATA_ONLY
        return 'dc_not_available.jpg'
      when VisibilityService::VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE
        return 'thumb-restricted.png'
      end
    end
  end
end
