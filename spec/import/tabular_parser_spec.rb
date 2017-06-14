require 'rails_helper'

describe Import::TabularParser do
  let(:parser) { described_class.parser(file) }

  context 'with CSV file' do
    let(:file) { 'spec/fixtures/imports/csv_import_test.csv' }

    it 'gives CSVParser' do
      expect(parser.is_a?(Import::CSVParser)).to eq true
    end
  end

  context 'with Excel XL file' do
    let(:file) { 'spec/fixtures/imports/excel_xl_import_test.xlsx' }

    it 'gives ExcelXLParser' do
      expect(parser.is_a?(Import::ExcelXLParser)).to eq true
    end
  end
end
