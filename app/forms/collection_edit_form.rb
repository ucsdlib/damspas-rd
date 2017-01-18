class CollectionEditForm < Hyrax::Forms::CollectionForm

  self.terms += [:brief_description, :general_note, :location_of_originals, :table_of_contents]
  self.terms += [:spatial, :topic, :created_date, :extent, :local_attribution, :finding_aid, :exhibit, :resource_type]
  delegate :creator, :topic, :spatial, to: :model
  delegate :created_date, to: :model
  delegate :extent, :local_attribution, :finding_aid, :exhibit, to: :model
  delegate :brief_description, :general_note, :location_of_originals, :table_of_contents, to: :model
  delegate :resource_type, :language, to: :model

  def self.model_attributes(attrs)
    attrs[:title] = Array(attrs[:title]) if attrs[:title]
    # local authorities hashing
    attrs = super(attrs)
    attrs.dup.each do |key, value|
      if value.is_a? Array
        attrs[key].map! { |v| to_hash(v) }
      else
        attrs[key] = to_hash(value)
      end
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
