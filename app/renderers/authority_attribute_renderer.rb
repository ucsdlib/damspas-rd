class AuthorityAttributeRenderer < ::CurationConcerns::Renderers::AttributeRenderer

  # Draw the table row for the attribute
  def render
    markup = ''

    return markup if !values.present? && !options[:include_empty]
    markup << %(<tr><th>#{label}</th>\n<td><ul class='tabular'>)
    attributes = microdata_object_attributes(field).merge(class: "attribute #{field}")
    Array(values).each do |value|
      markup << "<li#{html_attributes(attributes)}>#{attribute_value_to_html(value)}</li>"
    end
    markup << %(</ul></td></tr>)
    markup.html_safe
  end

  private

    def li_value(value)
      display_text = value.to_s
      uri = value.to_s
      if (Authority.is_authority?(value))
        display_text = value.label.first
        uri = value.uri.to_s
      end
      link_to(ERB::Util.h(display_text), uri)
    end

    def search_path(value)
      Rails.application.routes.url_helpers.search_catalog_path(
        search_field: search_field, q: ERB::Util.h(value))
    end

    def search_field
      options.fetch(:search_field, field)
    end
end
