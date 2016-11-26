require 'rails_helper'

describe Agent do
  let(:subject) { described_class.new(label: ['Test Agent']) }

  describe '#label' do
    it 'has a label' do
      expect(subject.label).to eq ['Test Agent']
    end
  end

  describe '#alternateLabel' do
    let(:subject) { described_class.new(label: ['Test Agent'], alternate_label:['Alternate label']) }
    it 'has a label' do
      expect(subject.label).to eq ['Test Agent']
      expect(subject.alternate_label).to eq ['Alternate label']
    end
  end

  describe '#closeMatch' do
    let(:subject) { described_class.new(label: ['Test Agent'], close_match: ['http://test.com/closeMatch']) }
    let(:subject_error) { described_class.new(label: ['Test Agent'], close_match: ['xsd:anyURI']) }
    it 'should has closeMatch' do
      expect(subject.label).to eq ['Test Agent']
      expect(subject.close_match).to eq ['http://test.com/closeMatch']
    end
    it 'should raise error for invalid url' do
      expect(subject_error.label).to eq ['Test Agent']
      expect(subject_error.close_match).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error (Exception)
    end
  end

  describe '#relatedMatch' do
    let(:subject) { described_class.new(label: ['Test Agent'], related_match: ['http://test.com/relatedMatch']) }
    let(:subject_error) { described_class.new(label: ['Test Agent'], related_match: ['relatedMatch: xsd:anyURI']) }
    it 'should has relatedMatch' do
      expect(subject.label).to eq ['Test Agent']
      expect(subject.related_match).to eq ['http://test.com/relatedMatch']
    end
    it 'should raise error for invalid url' do
      expect(subject_error.label).to eq ['Test Agent']
      expect(subject_error.related_match).to eq ['relatedMatch: xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error (Exception)
    end
  end
end
