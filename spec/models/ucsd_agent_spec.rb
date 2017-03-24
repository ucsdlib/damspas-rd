require 'rails_helper'

describe UcsdAgent do
  let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person') }

  describe '#label' do
    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
    end
  end

  describe '#alternateLabel' do
    let(:subject) { described_class.new(label: 'Test Agent', alternate_label: 'Alternate label', agent_type: 'Person') }
    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.alternate_label).to eq 'Alternate label'
    end
  end

  describe '#agentType' do
    let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person') }
    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.agent_type).to eq 'Person'
    end
  end

  describe '#hasOrcid' do
    let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person', has_orcid: 'http://test.com/orcid/any') }
    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.has_orcid).to eq 'http://test.com/orcid/any'
    end
  end

  describe '#closeMatch' do
    let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person', close_match: ['http://test.com/closeMatch']) }
    let(:subject_error) { described_class.new(label: 'Test Agent', close_match: ['xsd:anyURI']) }
    it 'should has closeMatch' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.close_match).to eq ['http://test.com/closeMatch']
    end
    it 'should raise error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.close_match).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error (Exception)
    end
  end

  describe '#relatedMatch' do
    let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person', related_match: ['http://test.com/relatedMatch']) }
    let(:subject_error) { described_class.new(label: 'Test Agent', related_match: ['relatedMatch: xsd:anyURI']) }
    it 'should has relatedMatch' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.related_match).to eq ['http://test.com/relatedMatch']
    end
    it 'should raise error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.related_match).to eq ['relatedMatch: xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error (Exception)
    end
  end

  describe '#differentFrom' do
    let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person', different_from: ['http://test.com/differentFrom']) }
    let(:subject_error) { described_class.new(label: 'Test Agent', different_from: ['xsd:anyURI']) }
    it 'should has differentFrom' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.different_from).to eq ['http://test.com/differentFrom']
    end
    it 'should raise error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.different_from).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error (Exception)
    end
  end
end
