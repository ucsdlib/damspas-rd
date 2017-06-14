module InputBase
  def input(wrapper_options)
    super
  end

  protected

    # Delegate this completely to the form.
    def collection
      @collection ||= object[attribute_name].reject { |value| value.to_s.strip.blank? }
    end

    def build_field(value, index)
      options = input_html_options.dup

      options[:required] = nil if @rendered_first_element

      options[:class] ||= []
      options[:class] += ["#{input_dom_id} form-control multi-text-field"]
      options[:'aria-labelledby'] = label_id

      @rendered_first_element = true

      out = ''
      out << build_components(attribute_name, value, index, options)
      out << hidden_id_field(value, index) unless value.new_record?
      out
    end

    def build_field_html(resource, attribute_name, field, index, options = {})
      out = ''
      out << "<div class='row'>"
      field_name = name_for(attribute_name, index, field)
      label = options.key?(:label) ? options.delete(:label) : field

      text_field = build_text_field(resource, attribute_name, field, index, options)
      out << "  <div class='col-md-1'>"
      out << template.label_tag(field_name, label.to_s.humanize)
      out << '  </div>'

      out << "  <div class='col-md-5'>"
      out << text_field
      out << '  </div>'
      out << '</div>'
      out
    end

    def build_text_field(resource, attribute_name, field, index, options)
      field_name = name_for(attribute_name, index, field)
      field_value = resource.new_record? ? '' : resource.send(field).first
      if options.delete(:type) == 'select'.freeze
        options[:select_options].insert(0, [' - select - ', '']) if options.delete(:include_blank)
        template.select_tag("#{attribute_name}_#{index}_#{field}",
                            template.options_for_select(options.delete(:select_options), field_value),
                            options.merge(value: field_value, name: field_name))
      elsif options.delete(:type) == 'textarea'.freeze
        @builder.text_area("#{attribute_name}_#{index}_#{field}", options.merge(value: field_value, name: field_name))
      else
        @builder.text_field("#{attribute_name}_#{index}_#{field}", options.merge(value: field_value, name: field_name))
      end
    end

    def hidden_id_field(value, index)
      name = id_name_for(attribute_name, index)
      id = id_for(attribute_name, index, 'id'.freeze)
      hidden_value = value.new_record? ? '' : value.rdf_subject
      @builder.hidden_field(attribute_name, name: name, id: id, value: hidden_value, data: { id: 'remote' })
    end

    def build_options_for_new_row(_attribute_name, _index, options)
      options[:value] = ''
    end

    def build_options_for_existing_row(_attribute_name, _index, value, options)
      options[:value] = value.rdf_label.first || "Unable to fetch label for #{value.rdf_subject}"
    end

    def name_for(attribute_name, index, field)
      "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][#{field}][]"
    end

    def id_name_for(attribute_name, index)
      singular_input_name_for(attribute_name, index, 'id')
    end

    def destroy_name_for(attribute_name, index)
      singular_input_name_for(attribute_name, index, '_destroy')
    end

    def singular_input_name_for(attribute_name, index, field)
      "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][#{field}]"
    end

    def id_for(attribute_name, index, field)
      [@builder.object_name, "#{attribute_name}_attributes", index, field].join('_'.freeze)
    end
end
