# Generated via
#  `rails generate hyrax:work ObjectResource`
module Hyrax
  class ObjectResourceForm < Hyrax::Forms::WorkForm
    include SchemaEditFormBehavior

    self.model_class = ::ObjectResource

    def self.model_attributes(attrs)
      # local authorities hashing
      attrs = super(attrs)

      begin
      # language label conversion
      language_converted = attrs['language'].dup.map! { |v| LanguageSelectService.new.get_uri(v) || (raise ArgumentError.new('Invalid language error')) }
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

    protected

      def self.permitted_time_span_params
        [:id,
         :_destroy,
         {
           start: [],
           finish: [],
           label: [],
           note: [],
         },
        ]
      end

      def self.build_permitted_params
        permitted = super

        permitted << { created_date_attributes: permitted_time_span_params }
        permitted << { event_date_attributes: permitted_time_span_params }
      end

      def self.to_hash(val)
        begin
          val.start_with?(ActiveFedora.fedora.host) ? ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(val)).uri : val
        rescue
          val
        end
      end
  end
end
