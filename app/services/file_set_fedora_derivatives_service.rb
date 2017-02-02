# Override to create A/V derivatives for Fedora storage
class FileSetFedoraDerivativesService < Hyrax::FileSetDerivativesService

  private
    def create_audio_derivatives(filename)
      Hydra::Derivatives::AudioDerivatives.create(filename,
                                                  outputs: [{ object: file_set, label: :service_file, format: 'mp3', url: uri, container: "files" }])
    end

    def create_video_derivatives(filename)
      Hydra::Derivatives::VideoDerivatives.create(filename,
                                                  outputs: [{ label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
                                                            { object: file_set, label: :service_file, format: 'mp4', url: uri, container: "files" }])
    end
end
