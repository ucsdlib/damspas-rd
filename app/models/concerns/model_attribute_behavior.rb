module ModelAttributeBehavior
  extend ActiveSupport::Concern

  module ClassMethods
    def model_local_attributes(attrs)
      # nested attributes
      convert_nested_attributes attrs

      begin
        # language label conversion
        convert_languages attrs

      # Invalid language input will be caught by validation
      rescue ArgumentError => err
        Rails.logger.debug "Invalid language input (#{attrs['language'].inspect}): #{err}"
      end
      attrs
    end

    # convert nested attributes
    def convert_nested_attributes(attrs)
      attrs.dup.each do |key, _val|
        next unless key.ends_with? "_attributes"
        nested_attrs = model_nested_attributes attrs[key]
        nested_attrs.values.each { |bn_attrs| remove_blank_attributes!(bn_attrs) }
        attrs[key] = nested_attrs
      end
    end

    def convert_languages(attrs)
      language_converted = attrs['language'].dup.map! do |v|
        LanguageSelectService.new.get_uri(v) || (raise ArgumentError, 'Invalid language error')
      end
      attrs['language'] = language_converted
    end

    def permitted_time_span_params
      [:id,
       :_destroy,
       {
         start: [],
         finish: [],
         label: []
       }]
    end

    def permitted_related_resource_params
      [:id,
       :_destroy,
       {
         related_type: [],
         name: [],
         url: []
       }]
    end

    def build_permitted_params
      permitted = super

      permitted << { created_date_attributes: permitted_time_span_params }
      permitted << { event_date_attributes: permitted_time_span_params }
      permitted << { related_resource_attributes: permitted_related_resource_params }
    end

    # model nested _attributes with new elements that copied index and id from existing elements
    def model_nested_attributes(nested_attrs)
      count = 0
      {}.tap do |process|
        nested_attrs.each do |_i, e|
          (e.keys - ["id"]).each do |key|
            e[key].each_with_index.map do |val, idx|
              process[(idx + count).to_s] ||= {}
              process[(idx + count).to_s][key] = Array(val)
              process[(idx + count).to_s]["id"] = e["id"] if idx.zero? && (e.key?("id") && !e["id"].empty?)
            end
          end
          count += 1
        end
      end
    end

    def remove_blank_attributes!(attributes)
      multivalued_form_attributes(attributes).each_with_object(attributes) do |(k, v), h|
        h[k] = v.instance_of?(Array) ? v.select(&:present?) : v
      end
      attributes.each { |k, v| attributes[k] = nil if !v.nil? && v.to_s.strip.blank? }
    end

    # Return the hash of attributes that are multivalued and not uploaded files
    def multivalued_form_attributes(attributes)
      attributes.select { |_, v| v.respond_to?(:select) && !v.respond_to?(:read) }
    end
  end
end
