module LocalAuthorityValueConverter
  extend ActiveSupport::Concern

  # Convert local authority value to hash
  def authority_hash(attrs)
    attrs.dup.each do |k, v|
      if v.is_a? Array
        v.map! { |val| to_hash(val) }
      else
        attrs[k] = to_hash(v)
      end
    end
  end

  def to_hash(val)
    val.start_with?(ActiveFedora.fedora.host) ? ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(val)).uri : val
  rescue
    val
  end
end
