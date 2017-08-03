# frozen_string_literal: true

class FileSetIndexer < Hyrax::FileSetIndexer
  self.thumbnail_path_service = ::ThumbnailPathService

  def generate_solr_document
    super.tap do |solr_doc|
      file_uses.each do |file_use|
        file_metadata = file_metadata(object.send(file_use))
        file_metadata = file_metadata.merge(file_use: file_use)
        Solrizer.insert_field(solr_doc, "files_json", file_metadata.to_json, :stored_searchable)
      end
    end
  end

  def file_uses
    [].tap do |process|
      process << :original_file if object.original_file
      process << :preservation_master_file if object.preservation_master_file
      process << :transcript if object.transcript
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def file_metadata(file)
    {}.tap do |attrs|
      attrs[:uri] = file.uri.to_s
      attrs[:label] = file.label.first if file.label.present?
      attrs[:file_name] = file.file_name.first
      attrs[:file_format] = format(file)
      attrs[:file_size] = file.file_size.present? ? file.file_size.first : file.content.size
      attrs[:height] = Integer(file.height.first) if file.height.present?
      attrs[:width] = Integer(file.width.first) if file.width.present?
      attrs[:mime_type] = file.mime_type
      attrs[:digest] = file.digest.first.to_s
      attrs[:file_title] = file.file_title.first if file.file_title.present?
      attrs[:duration] = file.duration.first if file.duration.present?
      attrs[:sample_rate] = file.sample_rate.first if file.sample_rate.present?
      attrs[:original_checksum] = file.original_checksum.first
      attrs[:date_uploaded] = file.date_modified.present? ? file.date_modified.first : file.create_date
    end
  end

  private

    def format(file)
      if file.mime_type.present? && file.format_label.present?
        "#{file.mime_type.split('/').last} (#{file.format_label.join(', ')})"
      elsif file.mime_type.present?
        file.mime_type.split('/').last
      elsif file.format_label.present?
        file.format_label
      end
    end
end
