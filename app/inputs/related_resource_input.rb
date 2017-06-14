class RelatedResourceInput < MultiValueInput
  include InputBase

  def input_type
    'multi_value'.freeze
  end

  protected

    def build_components(attribute_name, value, index, options)
      out = ''

      # --- :related_type
      out << build_field_html(value, attribute_name, :related_type, index,
                              options.merge(placeholder: '', type: 'select'.freeze,
                                            select_options: select_options, label: 'type', include_blank: true))

      # --- :name
      out << build_field_html(value, attribute_name, :name, index, options.merge(placeholder: ''))

      # --- :url
      out << build_field_html(value, attribute_name, :url, index, options.merge(placeholder: ''))
      out
    end

  private

    def select_options
      @select_options ||= begin
        collection = MetadataService.find_all_related_resource_types
        collection.respond_to?(:call) ? collection.call : collection.to_a
      end
    end
end
