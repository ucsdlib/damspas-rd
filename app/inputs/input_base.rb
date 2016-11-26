module InputBase

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
