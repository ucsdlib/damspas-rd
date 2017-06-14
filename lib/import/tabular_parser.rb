module Import
  class TabularParser
    include Enumerable
    include TabularBasic

    attr_reader :data, :headers

    def self.parser(metadata_source)
      if metadata_source.ends_with? '.csv'
        CSVParser.new(metadata_source)
      elsif metadata_source.ends_with? '.xlsx'
        ExcelXLParser.new(metadata_source)
      else
        raise NotImplementedError, 'Metadata source format not supported: #{metadata_source}'
      end
    end

    def initialize(data)
      @data = data
    end

    # yield the attributes from one row of the file
    def each(&_block)
      @data.each do |row|
        continue if row.nil?
        if @headers
          yield attributes(headers, row)
        else
          @headers = parse_headers(row)
        end
      end
    end

    private

      # attributes for a record
      def attributes(headers, row)
        {}.tap do |attrs|
          headers.each_with_index do |header, index|
            extract_field(header, row[index], attrs)
            attrs.dup.each do |k, v|
              attrs.delete k
              split_values(k, v, attrs)
            end
          end
        end
      end

      # attributes in a record
      def split_values(key, values, attrs)
        attrs[key] ||= []
        values.each do |val|
          vals = parse_value(val)
          attrs[key].push(*vals)
        end
      end

      def parse_value(val)
        return Array(val) if val.to_s.index('|').nil?
        [].tap do |vals|
          parse_escaped_values vals, val
        end
      end

      def parse_escaped_values(vals, val)
        s = []
        val.each_char do |char|
          if char == '|'
            if s[-1] == '\\'
              s[-1] = '|'
            else
              vals << s.join.strip
              s = []
            end
          else
            s << char
          end
        end

        vals << s.join.strip unless s.empty?
      end
  end
end
