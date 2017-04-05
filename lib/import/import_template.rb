module Import
  class ImportTemplate
    include Enumerable
    include TabularBasic

    attr_reader :headers
    attr_reader :control_values
    attr_reader :key_values

    def initialize(header_sheet, cv_sheet, key_value_sheet)
      extract_headers header_sheet
      extract_control_values cv_sheet
      extract_key_values key_value_sheet
    end

    def self.from_file(filename)
      work_book = RubyXL::Parser.parse(filename)
      ImportTemplate.new(work_book['Header list'], work_book['CV values'], work_book['Formatted key-value rules'])
    end

    private
      # field value
      def field_value(cell)
        val = cell.value if cell
        val.nil? ? val : val.to_s.strip
      end

      def extract_headers(sheet)
        headers ||= {}
        parse_sheet(sheet, headers)
        @headers = headers['Header label']
      end

      def extract_control_values(sheet)
        @control_values ||= {}
        parse_sheet sheet, @control_values
      end

      def extract_key_values(sheet)
        @key_values ||= {}
        parse_sheet sheet, @key_values
      end

      def parse_sheet(sheet, values = {})
        headers = nil
        sheet.each do |row|
          if headers
            attributes(headers, row).each do |k, v|
              values[k] ||= []
              values[k].push *v if !v.blank?
            end
          else
            headers = parse_headers row
          end
        end
      end
  end
end