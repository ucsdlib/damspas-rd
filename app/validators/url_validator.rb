class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << (options[:message] || "field is not a valid URL") unless url_valid?(value, options)
  end

  def url_valid?(value, options)
    result = true
    if value.is_a? ActiveTriples::Relation
      value.each { |url| result=false if url.is_a?(String) && (options[:allow_blank].nil? || !(options[:allow_blank] && url.to_s.length==0)) && !is_url?(url) }
    else
      result = is_url? value
    end
    result
  end

  def is_url?(url)
    url = URI.parse(url) rescue false
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end
end
