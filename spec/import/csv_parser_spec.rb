require 'rails_helper'

describe Import::CSVParser do
  let(:parser) { described_class.new(file) }
  let(:file) { 'spec/fixtures/imports/csv_import_test.csv' }
  let(:first_record) { parser.first }

  context 'Import a simple record' do
    it 'parses a record' do
      # object unique id must be singular
      expect(first_record["object unique id"]).to eq ['object#1']

      # level must be singular
      expect(first_record["level"]).to eq ['Object']

      expect(first_record["title"]).to eq ['Test Object One']

      expect(first_record["date:created"]).to eq ['Decenber 10, 2016 @{begin=2016-12-10 ; end=2016-12-10 }']

      expect(first_record["type of resource"]).to eq ['http://id.loc.gov/vocabulary/resourceTypes/img', 'http://id.loc.gov/vocabulary/resourceTypes/mix']

      expect(first_record.keys).to match_array ["object unique id", "level", "title", "date:created", "type of resource"]
    end
  end
end
