module LocalAuthorityHashAccessor
  extend ActiveSupport::Concern

  # Override the hash accessor to cast local authorities to AF::Base
  def [] (arg)
    reflection = self.class.reflect_on_association(arg.to_sym)
    # Checking this avoids setting properties like head_id (belongs_to) to an array
    if (reflection && reflection.collection?) || !reflection
      Array(super).each {|val| to_hash(val)}
    else
      super
    end

  end

  private
    def to_hash(val)
      begin
        if val.start_with?(ActiveFedora.fedora.host) && ActiveFedora::Base.exists?(ActiveFedora::Base.uri_to_id(val.to_s))
          ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(val))
        elsif val.starts_with?(Rails.configuration.authority_path) && ActiveFedora::Base.exists?(val.to_s.gsub(/.*\//,''))
          ActiveFedora::Base.find(val.to_s.gsub(/.*\//,''))
        else
          val
        end
      rescue
        val
      end
    end
end
