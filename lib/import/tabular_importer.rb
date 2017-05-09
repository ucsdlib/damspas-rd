module Import
  class TabularImporter
    OBJECT = 1
    COMPONENT = 2
    SUBCOMPONENT = 3
    MULTI_VALUE_DELIMITER = '|'
    NESTED_ATTRIBUTE_SEPARATOR = '@'
    NESTED_ATTRIBUTE_BEGIN_CHAR = '{'
    NESTED_ATTRIBUTE_END_CHAR = '}'
    KEY_VALUE_PAIR_DELIMITER = ';'
    KEY_VALUE_DELIMITER = '='

    OBJECT_UNIQUE_ID = 'object unique id'
    LEVEL = 'level'

    attr_reader :user
    attr_reader :tabular_parser
    attr_reader :uploaded_files
    attr_reader :remote_files
    attr_reader :form_attributes
    attr_reader :tabular_tamplate

    attr_reader :data, :invaild_headers, :invaild_control_values, :invaild_key_values, :report, :log, :status

    # This construct the TabularImportor instance from source data file, source files, and a template file
    # @param [User] user
    # @param [String] data_file
    # @param [Hash] uploaded_files
    # @param [Hash] form_attributes
    # @param [String] template_file
    def initialize(user, data_file, uploaded_files, remote_files, form_attributes, template_file, log)
      @user = user
      @tabular_parser = TabularParser.parser(data_file)
      @uploaded_files = uploaded_files
      @remote_files = remote_files
      @form_attributes = form_attributes
      @template = ImportTemplate.from_file(template_file)
      @log = log

      @data = Array.new
      @invaild_headers = Array.new
      @invaild_control_values = Hash.new
      @invaild_key_values = Hash.new
      @report = StringIO.new
    end

    # ingest source records
    def import
      @status = validate
      return self unless @status

      parent_object = nil
      components = []
      model = model_to_create(form_attributes)

      @data.each do |attrs|
        attrs = model_attrs(attrs).with_indifferent_access

        # object unique id
        object_unique_id = attrs.delete :object_unique_id
        # level for building complex object: Object, Component, Sub-component
        level = attrs['level']

        # FIXME: file use properties
        file_1_use = attrs.delete :file_1_use
        file_2_use = attrs.delete :file_2_use


        # FIXME: license, it's changed in upstream in the master branch with Hyrax 1.0
        license = attrs.delete(:license).first if attrs.key? :license
        visibility = VisibilityService.visibility_value(attrs.delete(:rights_override).first) if attrs.key? :rights_override
        visibility_during_embargo = VisibilityService.visibility_value(attrs.delete(:visibility_during_embargo).first) if attrs.key? :visibility_during_embargo
        embargo_release_date = attrs.delete(:embargo_release_date).first if attrs.key? :embargo_release_date

        # source file
        process_source_file attrs

        attrs = attrs.merge @form_attributes

        # override license, visibility, embargo_release_date etc. if it is provided in the source metadata
        attrs[:license] = license if !license.blank?
        attrs[:visibility] = visibility if !visibility.blank?
        attrs[:visibility_during_embargo] = visibility_during_embargo if !visibility_during_embargo.blank?
        attrs[:embargo_release_date] = embargo_release_date if !embargo_release_date.blank?

        if level.gsub('-', '').upcase == 'OBJECT' && !components.empty?
          # ingest object
          child_log = Hyrax::Operation.create!(user: @user,
                                               operation_type: "Create Work",
                                               parent: @log)
          IngestWorkJob.perform_later(@user, model.to_s, components, child_log)
          components = []
        else
          components << attrs
        end
      end

      if components.count > 0
          # ingest object
          child_log = Hyrax::Operation.create!(user: @user,
                                               operation_type: "Create Work",
                                               parent: @log)
          IngestWorkJob.perform_later(@user, model.to_s, components, child_log)
      end

      @status = true
      self
    end

    # validate the source metadata
    # @return [bool]
    def validate
      tabular_parser.each do |attrs|
        @data << attrs
        attrs.each do |key, val|
          val.each do |value|

            # check for invalid control values
            if @template.control_values.key?(key)
              control_values = @template.control_values[key]
              if !control_values.include? value

                @invaild_control_values[attrs[OBJECT_UNIQUE_ID]] ||= []
                @invaild_control_values[attrs[OBJECT_UNIQUE_ID]] << key
              end
            end

            # validate key/value pairs
            next unless /@\s*{/.match(value)

            valid_keys = @template.key_values["Allowed key"]
            is_kv_valid = true
            kv_hash = extract_key_values(value)

            # ignore the default :label key for the value
            kv_hash.delete :label if kv_hash.key? :label
            kv_hash.each do |k, v|
              is_kv_valid = false if !(valid_keys.include?(k) || valid_keys.include?("#{k}:")) || v.blank?
              next unless is_kv_valid

              # validate data format
              case k
              when /uri:?/
                is_kv_valid = false if !looks_like_uri?(v)
              when /begin:?|end:?/
                begin
                  DateTime.parse(v)
                rescue ArgumentError
                  is_kv_valid = false
                end
              when /relatedType:?/
                control_values = @template.control_values['RelatedResource Type']
                is_kv_valid = false if !control_values.include?(v)
              end
            end

            next unless !is_kv_valid
            @invaild_key_values[attrs[OBJECT_UNIQUE_ID]] ||= []
            @invaild_key_values[attrs[OBJECT_UNIQUE_ID]] << key

          end
        end
      end

      # check for invalid headers
      @invaild_headers = @tabular_parser.headers - @template.headers
      @invaild_headers.size == 0 && @invaild_control_values.size == 0 && @invaild_key_values.size == 0
    end

    def looks_like_uri?(str)
      str =~ /^https?:\/\//
    end

    private
      # model raw attributes from import template
      # @parameter [Hash] attrs
      # @return: [Hash]
      def model_attrs(attrs = {})
        {}.tap do |process|
          attrs.dup.keys.each do |key|

            attr_key = name_to_symbol(key.to_s)
            val = attrs.delete key
            case key
            when /^(title)/, /^(note)/
              # fields with literal or uri
              process[attr_key] = val
            when /^(identifier)/
              # identifiers: single value
              process[attr_key] = single_value val
            when /^(agent:)/, 'subject:name', 'rights holder'
              # convert Agent
              process[attr_key] = authority_hash key, val, 'UcsdAgent'
            when /^(date:)/, 'date', 'subject:temporal'
              # convert TimeSpan
              nested_attrs = convert_nested_attribute val, 'label'
              # rename key: begin/end to start/finish
              nested_attrs.each do |ori_attrs|
                ori_attrs["start"] = ori_attrs.delete("begin") if ori_attrs.key? "begin"
                ori_attrs["finish"] = ori_attrs.delete("end") if ori_attrs.key? "end"
              end
              process["#{attr_key.to_s}_attributes"] = nested_attrs
            when 'related resource'
              # convert related resource: RelatedResource
              nested_attrs = convert_nested_attribute val, 'name'
              # rename key: type to related_type
              nested_attrs.each { |ori_attrs| ori_attrs["related_type"] = ori_attrs.delete("relatedType") if ori_attrs.key? "relatedType" }
              process["#{attr_key.to_s}_attributes"] = nested_attrs
            when 'subject:spatial'
              # convert Place
              process[attr_key] = authority_hash key, val, 'Place'
            when /^(subject:)/
              # convert Concept
              process[attr_key] = authority_hash key, val, 'Concept'
            when 'level', 'object unique id', 'exhibit', 'finding_aid', 'location_of_originals', 'brief_description'
              process[attr_key] = single_value val
            else
              process[attr_key] = match_control_value(key, val)
            end
          end
        end
      end

      # @parameter [str]: encoded string value
      # @param [String] val_key: the prefer key for the nested value
      # @return: key/value [Hash]
      def extract_key_values(str, val_key='label')
        values = str.split(NESTED_ATTRIBUTE_SEPARATOR)
        kv_str = values[-1].strip
        return {val_key.to_sym => str} unless kv_str.starts_with?(NESTED_ATTRIBUTE_BEGIN_CHAR) && kv_str.ends_with?(NESTED_ATTRIBUTE_END_CHAR)
        {}.tap do |kv_hash|
          # add label to the hash
          kv_hash[val_key.to_sym] = values[0] if kv_hash.count == 0
          kv_str[1, kv_str.size-2].split(KEY_VALUE_PAIR_DELIMITER).each do |kv|
            pair = kv.split(KEY_VALUE_DELIMITER)
            case pair.size
              when 1
                kv_hash[pair[0].strip] = nil
              else
                kv_hash[pair[0].strip] = pair[-1].strip
              end
          end
        end
      end

      # Override this method if you have a different rubric for choosing the model
      # @param [Hash] attributes
      # @return: [String] the model to create
      def model_to_create(attributes)
        Hyrax.config.model_to_create.call(attributes)
      end

      # convert authority attributes
      # @param [String] type: header type
      # @param [Array] val: values to convert
      # @param [string] model: model name
      # @return: [Hash]
      def authority_hash(type, val, model)
        val.map do |label|
          au = AuthoritiesService.find_or_create(model, label)
          raise "Unable to create new #{model} #{label} for #{type}." if au.id.nil?
          ActiveFedora::Base.id_to_uri(au.id)
        end
      end

      def process_source_file(attrs)

        # file path: when appearing ignore uploaded files
        file_path = attrs.delete(:file_path).first if attrs.key? :file_path
        if file_path.nil?
          matched_uploaded_files = []
          matched_remote_files = []
          map_files attrs, :file_1_name, uploaded_files, remote_files, matched_uploaded_files, matched_remote_files if attrs.include?(:file_1_name)
          map_files attrs, :file_2_name, uploaded_files, remote_files, matched_uploaded_files, matched_remote_files if attrs.include?(:file_2_name)

          attrs[:uploaded_files] = matched_uploaded_files
          attrs[:remote_files] = matched_remote_files
        else
          attrs[:remote_files] = []
          file_1_name = attrs.delete(:file_1_name).first if attrs.key? :file_1_name
          file_2_name = attrs.delete(:file_2_name).first if attrs.key? :file_2_name
          attrs[:remote_files] << { :url => "file://#{file_path}/#{file_1_name}", :file_name => "#{file_1_name}"}.with_indifferent_access if !file_1_name.nil?
          attrs[:remote_files] << { :url => "file://#{file_path}/#{file_2_name}", :file_name => "#{file_2_name}"}.with_indifferent_access if !file_2_name.nil?
        end
      end

      # map source files for object/component
      # @param [Hash] attrs
      # @param [String] file_header
      # @param [Hash] uploaded_files_map
      # @param [Hash] remote_files_map
      # @param [Array] matched_files: uploaded files that are matched
      # @param [Array] remote_files: remote files that are matched
      def map_files(attrs, file_header, uploaded_files_map, remote_files_map, matched_files, remote_files)
        file_name = attrs[file_header].first
        matched_files << uploaded_files_map[file_name] if uploaded_files_map.key?(file_name)
        remote_files << remote_files_map[file_name] if remote_files_map.key?(file_name)
        attrs.delete(file_header)
      end

      # convert nested attribute
      # @param [String] nested_string: encoded key/value string @{key=value;...}
      # @param [String] value_key: key for the nested value
      # @param [Hash] remote_files_map
      def convert_nested_attribute(nested_string, value_key)
        nested_string.map { |val| extract_key_values(val, value_key) }
      end

      # convert property name to symbol
      # @param [String] name: name to convert
      def name_to_symbol(name)
        case name
        when 'type of resource'
          'resource_type'.to_sym
        when /^(date:)/
          "#{name.split(':')[-1]}_date"
        else
          name = name.split(':')[-1] if !name.index(':').nil?
          name.gsub(' ', '_').to_sym
        end
      end

      # single value property
      # @param [Array|String]
      # @return: [String]
      def single_value(val)
        val.is_a?(Array) ? val.first : val
      end

      # match the raw control value to the expected value in object import template
      # @param [String] key: header name
      # @param [Array|String] val: value to match
      # @return [Array|String]
      def match_control_value(key, val)
        return val unless @template.control_values.key?("#{key} MATCH")
        if val.is_a? Array
          val.map { |v| get_match_value(key, v) }
        else
          get_match_value key, val
        end
      end

      # match the input value to the expected value in the object import template
      # @param [String] key: header name
      # @param [Array|String] val: value to match
      # @return [String]
      def get_match_value(key, val)
        index = @template.control_values[key].index(val)
        index.nil? ? val : @template.control_values["#{key} MATCH"][index]
      end
  end
end
