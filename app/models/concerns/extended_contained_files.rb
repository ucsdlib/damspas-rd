module ExtendedContainedFiles
  extend ActiveSupport::Concern

  # Extend HydraWorks to support ServiceFile for video/audio files.
  included do
    directly_contains_one :service_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#ServiceFile'), class_name: 'Hydra::PCDM::File'
  end
end