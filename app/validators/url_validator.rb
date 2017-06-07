class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "field is not a valid URL") unless url_valid?(value, options)
  end

  def url_valid?(value, options)
    result = true
    if value.is_a? ActiveTriples::Relation
      value.each do |url|
        result = false if (options[:allow_blank].nil? || !(options[:allow_blank] && url.to_s.empty?)) && !url?(url)
      end
    else
      result = url? value
    end
    result
  end

  def url?(url)
    url = begin
            URI.parse(url)
          rescue
            false
          end
    url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end
end
