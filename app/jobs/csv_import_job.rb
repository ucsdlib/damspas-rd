require 'csv_parser'
class CsvImportJob < ApplicationJob
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
  def perform(user, csv_source, uploaded_files, selected_files, attributes, log)
    log.performing!

    create(user, csv_source, uploaded_files, selected_files, attributes, log)
  end

  private

    def create(user, csv_source, uploaded_files, selected_files, attributes, log)

      uploaded_files_map = {}
      remote_files_map = {}

      uploaded_files.each do |id|
        f = Hyrax::UploadedFile.find(id).file if !id.blank?
        uploaded_files_map[File.basename(f.current_path)] = id
      end

      selected_files.each do |f|
        remote_files_map[f[:file_name]] = f
      end

      model = model_to_create(attributes) #::ObjectResource #
      parser = CSVParser.new(csv_source)
      parser.each do |attrs|
        split_attributes (attrs)

        # topic field
        auth_arr = authority_hash attrs, :Topic, 'Concept'
        attrs = attrs.merge(topic: auth_arr)

        # creator field
        auth_arr = authority_hash attrs, :Creator, 'Agent'
        attrs = attrs.merge(creator: auth_arr)

        # Language field
        auth_arr = attrs.delete(:Language)
        attrs = attrs.merge(language: auth_arr)

        # Resource Type field
        auth_arr = attrs.delete(:Type)
        attrs = attrs.merge(resource_type: auth_arr)

        matched_files = []
        remote_files = []

        map_files attrs, :file_1, uploaded_files_map, remote_files_map, matched_files, remote_files if attrs.include?(:file_1)
        map_files attrs, :file_2, uploaded_files_map, remote_files_map, matched_files, remote_files if attrs.include?(:file_2)

        attributes = attributes.merge(attrs)
        attributes[:uploaded_files] = matched_files
        attributes[:remote_files] = remote_files
        child_log = Hyrax::Operation.create!(user: user,
                                                      operation_type: "Create Work",
                                                      parent: log)
        IngestWorkJob.perform_later(user, model.to_s, attributes, child_log)

      end
    end

    # Override this method if you have a different rubric for choosing the model
    # @param [Hash] attributes
    # @return String the model to create
    def model_to_create(attributes)
      Hyrax.config.model_to_create.call(attributes)
    end

    def authority_hash (attrs, key, model)
      return attrs.delete(key).map { |label| AuthoritiesService.find_or_create(model, label) } if attrs.key?(key)
      []
    end

    def split_attributes (attrs)
      attrs.each do |key, val|
        arr = []
        val.first.to_s.split('|').map {|v| arr << v.strip}
        val.clear.push *arr
      end
    end

    def map_files (attrs, file_header, uploaded_files_map, remote_files_map, matched_files, remote_files)
      file_name = attrs[file_header].first
      matched_files << uploaded_files_map[file_name] if uploaded_files_map.key?(file_name)
      remote_files << remote_files_map[file_name] if remote_files_map.key?(file_name)
      attrs.delete(file_header)
    end
end
