module Import
  class TabularImporter
    OBJECT = 1
    COMPONENT = 2
    SUBCOMPONENT = 3
    MULTI_VALUE_DELIMITER = '|'.freeze
    NESTED_ATTRIBUTE_SEPARATOR = '@'.freeze
    NESTED_ATTRIBUTE_BEGIN_CHAR = '{'.freeze
    NESTED_ATTRIBUTE_END_CHAR = '}'.freeze
    KEY_VALUE_PAIR_DELIMITER = ';'.freeze
    KEY_VALUE_DELIMITER = '='.freeze

    OBJECT_UNIQUE_ID = 'object unique id'.freeze
    LEVEL = 'level'.freeze
    DEFAULT_FILE_USE = ExtendedContainedFiles::ORIGINAL_FILE

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

      @data = []
      @invaild_headers = []
      @invaild_control_values = {}
      @invaild_key_values = {}
      @report = StringIO.new
    end

    # ingest source records
    def import
      @status = validate
      return self unless @status

      model = model_to_create(form_attributes)
      components = []
      @data.each do |attrs|
        if attrs['level'].first.delete('-').casecmp('OBJECT').zero? && !components.empty?
          ingest_object(@user, model.to_s, components, @log)
          components = []
        end
        components << process_attributes(attrs)
      end

      # Ingest the last object in the batch
      ingest_object(@user, model.to_s, components, @log) if components.count.positive?

      @status = true
      self
    end

    # Identify the level for building complex object: Object, Component, Sub-component to perform object ingest
    def ingest_object(user, model, components, log)
      child_log = Hyrax::Operation.create!(user: user,
                                           operation_type: "Create Work",
                                           parent: log)
      IngestWorkJob.perform_later(user, model, components, child_log)
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
              unless control_values.include? value

                @invaild_control_values[attrs[OBJECT_UNIQUE_ID]] ||= []
                @invaild_control_values[attrs[OBJECT_UNIQUE_ID]] << key
              end
            end

            # validate key/value pairs
            next unless /@\s*{/.match?(value)

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
                is_kv_valid = false unless looks_like_uri?(v)
              when /begin:?|end:?/
                begin
                  DateTime.strptime(v, '%Y-%m-%d')
                rescue ArgumentError
                  is_kv_valid = false
                end
              when /relatedType:?/
                control_values = @template.control_values['RelatedResource Type']
                is_kv_valid = false unless control_values.include?(v)
              end
            end

            next if is_kv_valid
            @invaild_key_values[attrs[OBJECT_UNIQUE_ID]] ||= []
            @invaild_key_values[attrs[OBJECT_UNIQUE_ID]] << key
          end
        end
      end

      # check for invalid headers
      @invaild_headers = @tabular_parser.headers - @template.headers
      @invaild_headers.empty? && @invaild_control_values.empty? && @invaild_key_values.empty?
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
              process["#{attr_key}_attributes"] = nested_attrs
            when 'related resource'
              # convert related resource: RelatedResource
              nested_attrs = convert_nested_attribute val, 'name'
              # rename key: type to related_type
              nested_attrs.each do |ori_attrs|
                ori_attrs["related_type"] = ori_attrs.delete("relatedType") if ori_attrs.key? "relatedType"
              end
              process["#{attr_key}_attributes"] = nested_attrs
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
      def extract_key_values(str, val_key = 'label')
        values = str.split(NESTED_ATTRIBUTE_SEPARATOR)
        kv_str = values[-1].strip
        unless kv_str.starts_with?(NESTED_ATTRIBUTE_BEGIN_CHAR) && kv_str.ends_with?(NESTED_ATTRIBUTE_END_CHAR)
          return { val_key.to_sym => str }
        end
        convert_to_hash(val_key, values, kv_str)
      end

      def convert_to_hash(val_key, values, kv_str)
        {}.tap do |kv_hash|
          # add label to the hash
          kv_hash[val_key.to_sym] = values[0] if kv_hash.count.zero?
          kv_str[1, kv_str.size - 2].split(KEY_VALUE_PAIR_DELIMITER).each do |kv|
            pair = kv.split(KEY_VALUE_DELIMITER)
            kv_hash[pair[0].strip] = case pair.size
                                     when 1
                                       nil
                                     else
                                       pair[-1].strip
                                     end
          end
        end
      end

      # Override this method if you have a different rubric for choosing the model
      # @param [Hash] attributes
      # @return: [String] the model to create
      def model_to_create(attributes)
        attributes.delete(:model) || attributes.delete('model')
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
          if attrs.include?(:file_1_name)
            map_files attrs, :file_1_name, uploaded_files, remote_files, matched_uploaded_files, matched_remote_files
          end
          if attrs.include?(:file_2_name)
            map_files attrs, :file_2_name, uploaded_files, remote_files, matched_uploaded_files, matched_remote_files
          end

          attrs[:uploaded_files] = matched_uploaded_files
          attrs[:remote_files] = matched_remote_files
        else
          attrs[:remote_files] = []
          file_1_name = attrs.delete(:file_1_name).first if attrs.key? :file_1_name
          file_2_name = attrs.delete(:file_2_name).first if attrs.key? :file_2_name
          if file_1_name.present?
            file_url = "file://#{file_path}/#{file_1_name}"
            attrs[:remote_files] << { url: file_url, file_name: file_1_name.to_s }.with_indifferent_access
          end
          if file_2_name.present?
            file_url = "file://#{file_path}/#{file_2_name}"
            attrs[:remote_files] << { url: file_url, file_name: file_2_name.to_s }.with_indifferent_access
          end
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
          name = name.split(':')[-1] unless name.index(':').nil?
          name.tr(' ', '_').to_sym
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

      def process_attributes(attrs)
        attrs = model_attrs(attrs).with_indifferent_access

        # object unique id
        attrs.delete :object_unique_id

        # file use properties
        add_file_use(attrs, attrs.key?(:file_1_use) ? attrs.delete(:file_1_use) : []) if attrs.key? :file_1_name
        add_file_use(attrs, attrs.delete(:file_2_use)) if attrs.key?(:file_2_use)

        # source file
        process_source_file attrs

        attrs_dup = attrs.dup # copy for attributes comparing
        attrs = attrs.merge @form_attributes

        # Override attributes submitted from the form
        property_override(attrs, attrs_dup, :license)
        visibility_override(attrs, attrs_dup, :visibility)
        visibility_override(attrs, attrs_dup, :visibility_during_embargo)
        property_override(attrs, attrs_dup, :embargo_release_date)

        attrs
      end

      # override the value of a property
      # @param [Hash] attrs
      # @param [Hash] attrs_dup: prefer values
      # @param [String] attr_name
      # @return
      def property_override(attrs, attrs_dup, attr_name)
        return unless attrs_dup.key? attr_name
        value = attrs_dup.delete(attr_name)
        attrs[attr_name] = value if value.present?
      end

      # override the value of a property
      # @param [Hash] attrs
      # @param [Hash] attrs_dup: prefer values
      # @param [String] attr_name
      # @return
      def visibility_override(attrs, attrs_dup, attr_name)
        return unless attrs_dup.key? attr_name
        value = VisibilityService.visibility_value(attrs_dup.delete(attr_name).first)
        attrs[attr_name] = value if value.present?
      end

      # add file use to object
      # @param [Hash] attrs
      # @param [String] file_use
      # @return
      def add_file_use(attrs, file_use)
        if file_use.present?
          file_use = convert_file_use(file_use.first)
        elsif attrs[:file_1_name].present?
          file_use = DEFAULT_FILE_USE
        end

        attrs[:file_use] ||= []
        attrs[:file_use] << file_use
      end

      # convert the value of file use
      # @param [String] value
      # @return
      def convert_file_use(value)
        preservation_master_file = ExtendedContainedFiles::PRESERVATION_MASTER_FILE.camelize
        transcript = ExtendedContainedFiles::TRANSCRIPT.camelize
        original_file = ExtendedContainedFiles::ORIGINAL_FILE.camelize
        case value
        when preservation_master_file, transcript, original_file
          value.underscore
        else
          value
        end
      end
  end
end
