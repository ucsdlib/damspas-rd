require 'rails_helper'

describe UcsdAgent do
  let(:subject) { described_class.new(label: 'Test Agent', agent_type: 'Person') }

  describe '#label' do
    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
    end
  end

  describe '#alternateLabel' do
    let(:subject) do
      described_class.new(label: 'Test Agent', alternate_label: 'Alternate label', agent_type: 'Person')
    end

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
    let(:subject) do
      described_class.new(label: 'Test Agent', agent_type: 'Person', orcid: 'http://test.com/orcid/any')
    end

    it 'has a label' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.orcid).to eq 'http://test.com/orcid/any'
    end
  end

  describe '#closeMatch' do
    let(:subject) do
      described_class.new(label: 'Test Agent', agent_type: 'Person', close_match: ['http://test.com/closeMatch'])
    end
    let(:subject_error) { described_class.new(label: 'Test Agent', close_match: ['xsd:anyURI']) }

    it 'hases closeMatch' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.close_match).to eq ['http://test.com/closeMatch']
    end

    it 'raises error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.close_match).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error Exception
    end
  end

  describe '#relatedMatch' do
    let(:subject) do
      described_class.new(label: 'Test Agent', agent_type: 'Person', related_match: ['http://test.com/relatedMatch'])
    end
    let(:subject_error) { described_class.new(label: 'Test Agent', related_match: ['relatedMatch: xsd:anyURI']) }

    it 'hases relatedMatch' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.related_match).to eq ['http://test.com/relatedMatch']
    end

    it 'raises error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.related_match).to eq ['relatedMatch: xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error Exception
    end
  end

  describe '#differentFrom' do
    let(:subject) do
      described_class.new(label: 'Test Agent', agent_type: 'Person', different_from: ['http://test.com/differentFrom'])
    end
    let(:subject_error) { described_class.new(label: 'Test Agent', different_from: ['xsd:anyURI']) }

    it 'hases differentFrom' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.different_from).to eq ['http://test.com/differentFrom']
    end

    it 'raises error for invalid url' do
      expect(subject_error.label).to eq 'Test Agent'
      expect(subject_error.different_from).to eq ['xsd:anyURI']
      subject_error.save
      expect { subject_error.save! }.to raise_error Exception
    end
  end
end
