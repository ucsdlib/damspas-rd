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

        # FIXME: file use properties that need to handle
        file_1_use = attrs.delete 'file 1 use'
        file_2_use = attrs.delete 'file 2 use'

        attrs = model_attrs(attrs).with_indifferent_access

        object_unique_id = attrs.delete 'object unique id'
        level = attrs['level']
        date_created = attrs.delete 'date:created'

        # topic field
        auth_arr = authority_hash attrs, :"subject:topic", 'Concept'
        attrs = attrs.merge(topic: auth_arr)

        # creator field
        auth_arr = authority_hash attrs, :"agent:creator", 'Agent'
        attrs = attrs.merge(creator: auth_arr)

        # Language field
        auth_arr = attrs.delete(:language)
        attrs = attrs.merge(language: auth_arr)

        # Resource Type field
        auth_arr = attrs.delete(:"type of resource")
        attrs = attrs.merge(resource_type: auth_arr)

        matched_uploaded_files = []
        matched_remote_files = []

        map_files attrs, :"file 1 name", uploaded_files, remote_files, matched_uploaded_files, matched_remote_files if attrs.include?(:"file 1 name")
        map_files attrs, :"file 2 name", uploaded_files, remote_files, matched_uploaded_files, matched_remote_files if attrs.include?(:"file 2 name")

        attrs = attrs.merge @form_attributes
        attrs[:uploaded_files] = matched_uploaded_files
        attrs[:remote_files] = matched_remote_files

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

    def validate
      tabular_parser.each do |attrs|
        @data << attrs
        attrs.each do |key, val|
          val.each do |value|

            # check for invalid control values
            if @template.control_values.key?(key)
              control_values = @template.control_values.key?("#{key} MATCH") ? @template.control_values["#{key} MATCH"] : @template.control_values[key]
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
      # model attributes [Hash]
      def model_attrs(attrs = {})
        {}.tap do |process|
          attrs.each do |k, v|

            case k
            when /^(agent:)/
              # convert agent
              k = k.gsup('agent:', '').gsup(' ', '')
              process[k] = find_agents (v)
            when /^(identifier)/
              # single value
              process[k] = v.first
            when OBJECT_UNIQUE_ID, LEVEL
              process[k] = v.first
            else
              process[k] = v
            end
          end
        end
      end

      # @parameter [str]: encoded string value
      # @return: key/value [Hash]
      def extract_key_values(str)
        kv_str = str.split(NESTED_ATTRIBUTE_SEPARATOR)[-1].strip
        return Hash.new unless kv_str.starts_with?(NESTED_ATTRIBUTE_BEGIN_CHAR) && kv_str.ends_with?(NESTED_ATTRIBUTE_END_CHAR)
        {}.tap do |kv_hash|
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
      # @return String the model to create
      def model_to_create(attributes)
        Hyrax.config.model_to_create.call(attributes)
      end

      def authority_hash(attrs, key, model)
        return attrs.delete(key).map { |label| AuthoritiesService.find_or_create(model, label) } if attrs.key?(key)
        []
      end

      def map_files(attrs, file_header, uploaded_files_map, remote_files_map, matched_files, remote_files)
        file_name = attrs[file_header].first
        matched_files << uploaded_files_map[file_name] if uploaded_files_map.key?(file_name)
        remote_files << remote_files_map[file_name] if remote_files_map.key?(file_name)
        attrs.delete(file_header)
      end

  end
end
