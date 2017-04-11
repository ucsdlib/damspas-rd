module Import
  require 'csv'

  class CSVParser < TabularParser
    def initialize(source_file)
      super CSV.read(source_file).to_a
    end
  end
end
