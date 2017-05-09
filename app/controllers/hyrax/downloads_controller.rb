module Hyrax
  class DownloadsController < ApplicationController
    include Hyrax::DownloadBehavior

    # Overrides Hydrx::Controller::DownloadBehavior#load_file to load files for visibility metadata-oly and culturally sensitive.
    # Override this method to change which file is shown.
    # Loads the file specified by the HTTP parameter `:file`.
    # If this object does not have a file by that name, return the default file
    # as returned by {#default_file}
    # @return [ActiveFedora::File, String, NilClass] Returns the file from the repository or a path to a file on the local file system, if it exists.
    def load_file
      file_reference = params[:file]
      return default_file unless file_reference

      icon = icon_path(params[asset_param_key], true) if file_reference == 'thumbnail'
      return icon if !icon.nil?

      file_path = Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
      File.exist?(file_path) ? file_path : nil
    end


    # Customize the :read ability in your Ability class, or override this method.
    # Hydra::Ability#download_permissions can't be used in this case because it assumes
    # that files are in a LDP basic container, and thus, included in the asset's uri.
    def authorize_download!
      authorize! :read, params[asset_param_key]
    rescue CanCan::AccessDenied
      icon = icon_path params[asset_param_key]
      if icon
        redirect_to icon
      else
        redirect_to default_image
      end
    end

    # use static thumbnails for visibility metadata only and culturally sensitive objects
    # @param [string] asset_id
    def icon_path(asset_id, absolute_path=false)
      file_set = ActiveFedora::Base.where("id:#{asset_id}").first
      return if (can? :edit, file_set) || file_set.rights_override.blank?
      # retrieve icon
      return ::ThumbnailPathService.icon_file_path(VisibilityService.visibility_value(file_set.rights_override)) if absolute_path
      ::ThumbnailPathService.icon_path(VisibilityService.visibility_value(file_set.rights_override))
    end
  end
end
