class CollectionEditForm < Hyrax::Forms::CollectionForm
  include SchemaEditFormBehavior

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]) if attrs[:title]
    # local authorities hashing
    attrs = super(attrs)

    begin
    # language label conversion
    language_converted = attrs['language'].collect { |v| LanguageSelectService.new.get_uri(v) || (raise ArgumentError.new('Invalid language error')) }
    attrs['language'] = language_converted

    attrs.dup.each do |key, value|
      if value.is_a? Array
        attrs[key].map! { |v| to_hash(v) }
      elsif value.nil? || value.to_s.strip.blank?
          attrs.delete key
      else
        attrs[key] = to_hash(value)
      end
    end

    # Invalid language input will be caught by validation
    rescue ArgumentError => err
    end
    attrs
  end

  def initialize_fields
    super
  end

  def title
    self[:title].first
  end

  protected

    def self.to_hash(val)
      begin
        val.start_with?(ActiveFedora.fedora.host) ? ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(val)).uri : val
      rescue
        val
      end
    end
end
