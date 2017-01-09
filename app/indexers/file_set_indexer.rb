class FileSetIndexer < CurationConcerns::FileSetIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc[Solrizer.solr_name('service_file_digest', :symbol)] = digest_from_service_file_content
    end
  end

  private
    def digest_from_service_file_content
      return unless object.service_file
      object.service_file.digest.first.to_s
    end
end
