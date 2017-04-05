class BatchImportJob < ApplicationJob
  queue_as :ingest

  before_enqueue do |job|
    log = job.arguments.last
    log.pending_job(self)
  end

  # This copies metadata from the passed in attribute to all of the works that
  # are members of the given upload set
  # @param [User] user
  # @param [Array<Hyrax::UploadedFile>] uploaded_files
  # @param [Hash] attributes attributes to apply to all works
  # @param [BatchCreateOperation] log
  def perform(user, data_file, uploaded_files, selected_files, attributes, template_file, log)
    log.performing!

    create(user, data_file, uploaded_files, selected_files, attributes, template_file, log)
  end

  private

    def create(user, data_file, uploaded_files, selected_files, attributes, template_file, log)

      uploaded_files_map = {}
      remote_files_map = {}

      uploaded_files.each do |id|
        f = Hyrax::UploadedFile.find(id).file if !id.blank?
        uploaded_files_map[File.basename(f.current_path)] = id
      end

      selected_files.each do |f|
        remote_files_map[f[:file_name]] = f
      end

      #model = model_to_create(attributes) #::ObjectResource #

      Import::TabularImporter.new(user,
                                    data_file,
                                    uploaded_files_map,
                                    remote_files_map,
                                    attributes,
                                    template_file,
                                    log
                                    ).import
    end
end
