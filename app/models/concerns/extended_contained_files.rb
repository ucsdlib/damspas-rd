# rubocop:disable Metrics/LineLength
module ExtendedContainedFiles
  extend ActiveSupport::Concern
  ORIGINAL_FILE = 'original_file'.freeze
  PRESERVATION_MASTER_FILE = 'preservation_master_file'.freeze
  TRANSCRIPT = 'transcript'.freeze

  # Extend HydraWorks to support file use properties.
  included do
    directly_contains_one :preservation_master_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#PreservationMasterFile'), class_name: 'Hydra::PCDM::File'
    directly_contains_one :transcript, through: :files, type: ::RDF::URI('http://pcdm.org/use#Transcript'), class_name: 'Hydra::PCDM::File'
  end
end
