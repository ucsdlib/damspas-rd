# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToFileSetJob < AttachFilesToWorkJob
  queue_as Hyrax.config.ingest_queue_name

  ORIGINAL_FILE = ExtendedContainedFiles::ORIGINAL_FILE

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, file_uses, **work_attributes)
    user = User.find_by_user_key(work.depositor)

    file_set_files = []
    file_set_file_uses = []
    uploaded_files.each_with_index do |uploaded_file, index|
      file_use = file_uses.present? && file_uses.count > index ? file_uses[index] : ORIGINAL_FILE

      # One original_file one FileSet: multiple files with different file uses will be attached to a FileSet
      attach_files(user, work, work_attributes, file_set_files, file_set_file_uses) if file_use == ORIGINAL_FILE

      file_set_file_uses << file_use
      file_set_files << uploaded_file
    end

    # Files in the last file set that need attached
    attach_files(user, work, work_attributes, file_set_files, file_set_file_uses)
  end

  private

    # @param [Hyrax::Actors::FileSetActor] actor
    # @param [Hyrax::UploadedFile] uploaded_file .uploader.file must be a CarrierWave::SanitizedFile or
    #   .uploader.url must be present
    def attach_content(actor, uploaded_file, relation = ORIGINAL_FILE)
      file_uploader = uploaded_file.uploader
      if file_uploader.file.is_a? CarrierWave::SanitizedFile
        actor.create_content(file_uploader.file.to_file, relation)
      elsif file_uploader.url.present?
        actor.import_url(file_uploader.url, relation)
      else
        raise ArgumentError, "#{file_uploader.class} received with #{file_uploader.file.class} object and no URL"
      end
    end

    # Create file set
    def create_file_set(user, work, work_attributes, work_permissions)
      ::FileSet.new do |fs|
        actor = Hyrax::Actors::FileSetActor.new(fs, user)
        actor.create_metadata(visibility_attributes(work_attributes))
        actor.attach_to_work(work)
        fs.permissions_attributes = work_permissions
        fs.save!
      end
    end

    # Attached files to FileSet
    # @param [::FileSet] file_set
    # @param [Hyrax::UploadedFile] file_set_files
    # @param [Array] file_set_file_uses
    def attach_files(user, work, work_attributes, file_set_files, file_uses)
      return unless file_set_files.count.positive?

      work_permissions = work.permissions.map(&:to_hash)
      file_set = create_file_set(user, work, work_attributes, work_permissions)

      file_set_files.each_with_index do |uploaded_file, index|
        file_use = file_uses.present? && file_uses.count > index ? file_uses[index] : ORIGINAL_FILE

        uploaded_file.update(file_set_uri: file_set.uri)
        actor = FileSetAttachFilesActor.new(file_set, user)
        attach_content(actor, uploaded_file, file_use)
      end
      file_set_files.clear
      file_uses.clear
    end
end
