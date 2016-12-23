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
      file_path = params[:file]
      return default_file unless file_path

      if file_path == 'thumbnail'
        return asset.attached_files.base.thumbnail unless asset.attached_files.base.thumbnail.nil?
      elsif file_path == 'intermediate_file'
        return asset.attached_files.base.intermediate_file unless asset.attached_files.base.intermediate_file.nil?
      elsif file_path == 'service_file'
        return asset.attached_files.base.service_file unless asset.attached_files.base.service_file.nil?
      elsif file_path == 'original_file'
        return asset.attached_files.base.original_file unless asset.attached_files.base.original_file.nil?
      elsif file_path == 'preservation_master_file'
        return asset.attached_files.base.preservation_master_file unless asset.attached_files.base.preservation_master_file.nil?
      elsif file_path == 'extracted_text'
        return asset.attached_files.base.extracted_text unless asset.attached_files.base.extracted_text.nil?
      end
      nil
    end
end

