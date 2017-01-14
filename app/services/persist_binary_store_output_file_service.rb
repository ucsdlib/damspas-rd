  # This Service is an implementation of the Hydra::Derivatives::PeristOutputFileService
  # It supports basic contained files, which is the behavior associated with Fedora 4 binarystore
  # and, at the time that this class was authored, corresponds to the behavior of ActiveFedora::Base.attach_file and ActiveFedora::Base.attached_files
  ### Rename this
  class PersistBinaryStoreOutputFileService < Hyrax::PersistDerivatives
    # This method conforms to the signature of the .call method on Hydra::Derivatives::PeristOutputFileService
    # * Persists the file within the object at destination_name
    #
    # NOTE: Uses basic containment. If you want to use direct containment (ie. with PCDM) you must use a different service (ie. Hydra::Works::AddFileToGenericFile Service)
    #
    # @param [#read] stream the data to be persisted
    # @param [Hash] directives directions which can be used to determine where to persist to.
    # @option directives [String] url This can determine the path of the object.
    def self.call(stream, directives)
      format = directives[:format].to_s
      if directives.fetch(:label).to_s == 'service_file' && (format == 'mp3' || format == 'mp4')
        # Fedora server side derivative storage for Audio/Video
        file = Hydra::Derivatives::IoDecorator.new(stream)
        file.mime_type = new_mime_type(format)
        object = directives.fetch(:object)
        type = directives.fetch(:label)
        Hydra::Works::AddFileToFileSet.call(object, file, type, update_existing: true, versioning: false)
      else
        # Local disk thumbnail/derivative storage
        output_file(directives) do |output|
          IO.copy_stream(stream, output)
        end
      end
    end

    def self.new_mime_type(format)
      case format
      when 'mp4'
        'video/mp4' # default is application/mp4
      when 'webm'
        'video/webm' # default is audio/webm
      else
        MIME::Types.type_for(format).first.to_s
      end
    end
  end

