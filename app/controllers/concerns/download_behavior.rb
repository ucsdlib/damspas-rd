# Overrides CurationConcerns::DownloadBehavior to determine what file to load 
module DownloadBehavior
    extend ActiveSupport::Concern
  include CurationConcerns::DownloadBehavior

  protected
    # Overrides CurationConcerns::DownloadBehavior.
    # Override this method to change which file is shown.
    # Loads the file specified by the HTTP parameter `:file`.
    # If this object does not have a file by that name, return the default file
    # as returned by {#default_file}
    # @return [ActiveFedora::File, String, NilClass] Returns the file from the repository or a path to a file on the local file system, if it exists.
    def load_file

      file_reference = params[:file]
      return default_file unless file_reference
      if file_reference == 'service_file'
        return asset.attached_files.base.service_file unless asset.attached_files.base.service_file.nil?
      end

      file_path = CurationConcerns::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
      File.exist?(file_path) ? file_path : nil

    end
end

