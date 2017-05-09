require 'rails_helper'

describe Import::ExcelXLParser do
  let(:parser) { described_class.new(file) }
  let(:file) { 'spec/fixtures/imports/excel_xl_import_test.xlsx' }
  let(:first_record) { parser.first }

  context 'Import a simple record' do
    it 'parses a record' do
      # object unique id must be singular
      expect(first_record["object unique id"]).to eq ['object#1']

      # level must be singular
      expect(first_record["level"]).to eq ['Object']

      expect(first_record["title"]).to eq ['Test Object One']

      expect(first_record["date:created"]).to eq ['Decenber 10, 2016 @{begin=2016-12-10 ; end=2016-12-10 }']

      expect(first_record["type of resource"]).to eq ["mixed material", "still image"]

      expect(first_record.keys).to match_array ["object unique id", "level", "title", "subject:topic", "agent:creator", "agent:contributor", "subject:spatial", "date:created", "note:note", "identifier:doi", "language", "type of resource", "copyright jurisdiction", "copyright status", "rights holder", "license", "related resource"]
    end
  end
end
