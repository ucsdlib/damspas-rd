require 'uri'
require 'tmpdir'
require 'browse_everything/retriever'

# Given a FileSet that has an import_url property,
# download that file and put it into Fedora
# Called by AttachFilesToWorkJob (when files are uploaded to s3)
# and CreateWithRemoteFilesActor when files are located in some other service.
class ImportUrlWithFileUseJob < ::ImportUrlJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [Hyrax::BatchCreateOperation] operation
  def perform(file_set, operation, uri, relation)
    operation.performing!
    user = User.find_by_user_key(file_set.depositor)

    copy_remote_file(URI(uri)) do |f|
      # reload the FileSet once the data is copied since this is a long running task
      file_set.reload

      # FileSetActor operates synchronously so that this tempfile is available.
      # If asynchronous, the job might be invoked on a machine that did not have this temp file on its file system!
      # NOTE: The return status may be successful even if the content never attaches.
      if FileSetAttachFilesActor.new(file_set, user).create_content(f, relation)
        operation.success!
      else
        # send message to user on download failure
        Hyrax.config.callback.run(:after_import_url_failure, file_set, user)
        operation.fail!(file_set.errors.full_messages.join(' '))
      end
    end
  end
end
