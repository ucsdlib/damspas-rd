# Actions are decoupled from controller logic so that they may be called from a controller or a background job.
class FileSetAttachFilesActor < Hyrax::Actors::FileSetActor
  ORIGINAL_FILE = ExtendedContainedFiles::ORIGINAL_FILE
  # Spawns asynchronous IngestJob
  # Called from FileSetsController, AttachFilesToWorkJob, ImportURLJob, IngestLocalFileJob
  # @param [Hyrax::UploadedFile, File, ActionDigest::HTTP::UploadedFile] file the file uploaded by the user
  # @param [Symbol, #to_s] relation
  # @return [IngestJob, FalseClass] false on failure, otherwise the queued job
  def create_content(file, relation = ORIGINAL_FILE)
    # If the file set doesn't have a title or label assigned, set a default.
    file_set.label ||= label_for(file)
    file_set.title = [file_set.label] if file_set.title.blank?
    return false unless file_set.save # Need to save to get an id
    IngestJob.perform_later(wrapper!(file, relation))
  end

  # Spawns asynchronous IngestJob with user notification afterward
  # @param [Hyrax::UploadedFile, File, ActionDigest::HTTP::UploadedFile] file the file uploaded by the user
  # @param [Symbol, #to_s] relation
  # @return [IngestJob] the queued job
  def update_content(file, relation = ORIGINAL_FILE)
    IngestJob.perform_later(wrapper!(file, relation), notification: true)
  end

  # Spawns async ImportUrlJob to attach remote file to fileset
  # @param [#to_s] url
  # @return [IngestUrlJob] the queued job
  def import_url(url, relation = ORIGINAL_FILE)
    file_set.update(import_url: url.to_s)
    operation = Hyrax::Operation.create!(user: user, operation_type: "Attach File")
    ImportUrlWithFileUseJob.perform_later(file_set, operation, url, relation)
  end
end
