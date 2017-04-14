class TimeSpanInput < MultiValueInput
  include InputBase

  FORMAT_PLACEHOLDER = 'YYYY-MM-DD'.freeze

  protected

    def build_components(attribute_name, value, index, options)
      out = ''

      # --- :label
      out << build_field_html(value, attribute_name, :label, index, options.merge(placeholder: ''))

      # --- :start
      out << build_field_html(value, attribute_name, :start, index, options.merge(placeholder: FORMAT_PLACEHOLDER, label: 'begin'))

      # --- :finish
      out << build_field_html(value, attribute_name, :finish, index, options.merge(placeholder: FORMAT_PLACEHOLDER, label: 'end'))
      out
    end
end
