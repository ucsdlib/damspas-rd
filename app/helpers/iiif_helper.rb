module IiifHelper
  def iiif_url(solr_document)
    fedora_file = solr_document['digest_ssim'].first.split(':')[-1] if solr_document['digest_ssim'].present?
    fedora_file_pair_path = fedora_file.scan(/../)[0..2].join("%2F") + "%2F" + fedora_file
    "#{Rails.configuration.iiif_baseurl}#{fedora_file_pair_path}"
  end
end
