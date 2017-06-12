require 'rails_helper'

describe Authority do
  let(:subject) { described_class.new(label: 'Test Authority') }

  describe '#label' do
    it 'has a label' do
      expect(subject.label).to eq 'Test Authority'
    end
  end

  describe '#alternateLabel' do
    let(:subject) { described_class.new(label: 'Test Authority', alternate_label: 'Alternate label') }

    it 'has a label' do
      expect(subject.label).to eq 'Test Authority'
      expect(subject.alternate_label).to eq 'Alternate label'
    end
  end

  describe '#exactMatch' do
    let(:subject) { described_class.new(label: 'Test Authority', exact_match: ['http://test.com/exactMatch']) }
    let(:subject_error) { described_class.new(label: 'Test Authority', exact_match: ['xsd:anyURI']) }

    it 'hases exactMatch' do
      expect(subject.label).to eq 'Test Authority'
      expect(subject.exact_match).to eq ['http://test.com/exactMatch']
    end

    it 'raises error for invalid url' do
      expect(subject_error.label).to eq 'Test Authority'
      expect(subject_error.exact_match).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error Exception
    end
  end
end
