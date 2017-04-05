module Import
  module TabularBasic
    private 
      # valid header fields
      def parse_headers(row)
        headers = []
        $i = 0
        while $i < row.size() do
          headers << field_value(row[$i])
          $i = $i + 1
        end
        headers
      end

      # attributes for a record
      def attributes(headers, row)
        {}.tap do |attrs|
          headers.each_with_index do |header, index|
            extract_field(header, row[index], attrs)
          end
        end
      end

      # attributes in a record
      def extract_field(header, cell, attrs = {})
        val = field_value cell
        return unless !val.blank?
        attrs[header] ||= []
        attrs[header] << val
      end

      # extract field value
      def field_value(cell)
        cell.nil? ? cell : cell.to_s.strip
      end
  end
end