module Hyrax
  class DownloadsController < ApplicationController
    include Hydra::Controller::DownloadBehavior

    def self.default_content_path
      :original_file
    end

    # Render the 404 page if the file doesn't exist.
    # Otherwise renders the file.
    def show
      case file
      when ActiveFedora::File
        # For original files that are stored in fedora
        super
      when String
        # For derivatives stored on the local file system
        response.headers['Accept-Ranges'] = 'bytes'
        response.headers['Content-Length'] = File.size(file).to_s
        send_file file, derivative_download_options
      else
        raise ActiveFedora::ObjectNotFoundError
      end
    end

    private

      # Override the Hydra::Controller::DownloadBehavior#content_options so that
      # we have an attachement rather than 'inline'
      def content_options
        super.merge(disposition: 'attachment')
      end

      # Override this method if you want to change the options sent when downloading
      # a derivative file
      def derivative_download_options
        { type: mime_type_for(file), disposition: 'inline' }
      end

      # Customize the :read ability in your Ability class, or override this method.
      # Hydra::Ability#download_permissions can't be used in this case because it assumes
      # that files are in a LDP basic container, and thus, included in the asset's uri.
      def authorize_download!
        case params[:file]
        when ExtendedContainedFiles::PRESERVATION_MASTER_FILE
          authorize! :edit, params[asset_param_key]
        else
          authorize! :read, params[asset_param_key]
        end
      rescue CanCan::AccessDenied
        icon = icon_path params[asset_param_key]
        if icon
          redirect_to icon
        else
          redirect_to default_image
        end
      end

      def default_image
        ActionController::Base.helpers.image_path 'default.png'
      end

      # Overrides for metadata-oly and culturally sensitive icon display.
      # Overrides Hydra::Controller::DownloadBehavior#load_file with hard-coded to assume files are in BasicContainer.
      # Override this method to change which file is shown.
      # Loads the file specified by the HTTP parameter `:file`.
      # If this object does not have a file by that name, return the default file
      # as returned by {#default_file}
      # @return [ActiveFedora::File, String, NilClass]
      # Returns the file from the repository or a path to a file on the local file system, if it exists.
      def load_file
        file_reference = params[:file]
        return authorized_file_download(default_file) unless file_reference

        icon = icon_path(params[asset_param_key], true) if file_reference == 'thumbnail'
        return icon if icon

        file_content = relation_content(file_reference)
        return authorized_file_download(file_content) if file_content

        file_path = Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
        File.exist?(file_path) ? file_path : nil
      end

      def default_file
        default_file_reference = if asset.class.respond_to?(:default_file_path)
                                   asset.class.default_file_path
                                 else
                                   DownloadsController.default_content_path
                                 end
        association = dereference_file(default_file_reference)
        association&.reader
      end

      def mime_type_for(file)
        MIME::Types.type_for(File.extname(file)).first.content_type
      end

      def dereference_file(file_reference)
        return false if file_reference.nil?
        association = asset.association(file_reference.to_sym)
        association if association && association.is_a?(ActiveFedora::Associations::SingularAssociation)
      end

      # use static thumbnails for visibility metadata only and culturally sensitive objects
      # @param [string] asset_id
      def icon_path(asset_id, absolute_path = false)
        file_set = ActiveFedora::Base.where("id:#{asset_id}").first
        return if (can? :edit, file_set) || file_set.rights_override.blank?
        # retrieve icon
        if absolute_path
          return ::ThumbnailPathService.icon_file_path(VisibilityService.visibility_value(file_set.rights_override))
        end
        ::ThumbnailPathService.icon_path(VisibilityService.visibility_value(file_set.rights_override))
      end

      # Retrieve the content for relation
      # @param [string] relation
      # return [binary]
      def relation_content(relation)
        case relation
        when ExtendedContainedFiles::PRESERVATION_MASTER_FILE
          preservation_master_file = asset.attached_files.base.preservation_master_file
          return preservation_master_file if preservation_master_file
        when ExtendedContainedFiles::TRANSCRIPT
          return asset.attached_files.base.transcript if asset.attached_files.base.transcript
        end
      end

      def authorized_file_download(file_content)
        return file_content unless file_content.is_a?(ActiveFedora::File)
        if can?(:read, file_content)
          file_content
        else
          # return the lower resolution service image
          Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], 'thumbnail')
        end
      end
  end
end
