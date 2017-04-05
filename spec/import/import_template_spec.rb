require 'rails_helper'

describe Import::ImportTemplate do
  let(:template) { described_class.from_file(file) }
  let(:file) { 'spec/fixtures/imports/object_import_template.xlsx' }
  let(:headers) { template.headers }
  let(:control_values) { template.control_values }
  let(:key_values) { template.key_values }

  context 'batch import template' do
    it 'should contain valid headers' do
      expect(headers.count).not_to eql(0)

      expect(headers).to include(*["object unique id", "level", "title", "file 1 name", "file 1 use", "date:created", "type of resource"])
    end

    it 'should contain control values' do
      expect(control_values.count).not_to eql(0)

      expect(control_values).to include({"level" => ["Object", "Component", "Sub-component"]})
    end

    it 'should contain key values' do
      expect(key_values.count).not_to eql(0)

      expect(key_values).to include({"Allowed key" => ["begin:", "end:", "uri:"]})
    end
  end
end
