module Import
  require 'rubyXL'

  class ExcelXLParser < TabularParser
    def initialize(source_file)
      super RubyXL::Parser.parse(source_file)[0]
    end

    private

      # field value
      def field_value(cell)
        val = cell.value if cell
        val.nil? ? "" : val.to_s.strip
      end
  end
end
