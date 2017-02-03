# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include ::ExtendedContainedFiles
  include ::CommonMetadata

  Hydra::Derivatives.output_file_service = PersistBinaryStoreOutputFileService

  def self.indexer
    ::FileSetIndexer
  end

  private
    def file_set_derivatives_service
      @file_set_derivatives_service = ::FileSetFedoraDerivativesService.new(self)
    end
end

