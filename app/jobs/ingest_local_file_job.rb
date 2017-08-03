class IngestLocalFileJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] path
  # @param [User] user
  def perform(file_set, path, user, relation = ExtendedContainedFiles::ORIGINAL_FILE)
    file_set.label ||= File.basename(path)

    actor = FileSetAttachFilesActor.new(file_set, user)

    status = actor.create_content(File.open(path), relation)
    if status
      # FileUtils.rm(path)
      Hyrax.config.callback.run(:after_import_local_file_success, file_set, user, path)
    else
      Hyrax.config.callback.run(:after_import_local_file_failure, file_set, user, path)
    end
  end
end
