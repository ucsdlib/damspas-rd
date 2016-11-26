require 'rails_helper'

describe Place do
  let(:subject) { described_class.new(label: ['Test Place']) }

  describe '#label' do
    it 'has a label' do
      expect(subject.label).to eq ['Test Place']
    end
  end

  describe '#alternateLabel' do
    let(:subject) { described_class.new(label: ['Test Place'], alternate_label:['Alternate label']) }
    it 'has a label' do
      expect(subject.label).to eq ['Test Place']
      expect(subject.alternate_label).to eq ['Alternate label']
    end
  end

  describe '#note' do
    let(:subject) { described_class.new(label: ['Test Place'], note: ['Note']) }
    it 'should has note' do
      expect(subject.label).to eq ['Test Place']
      expect(subject.note).to eq ['Note']
    end
  end

  describe '#point' do
    let(:subject) { described_class.new(label: ['Test Place'], point: '1.0000 2.0000') }
    it 'should has point' do
      expect(subject.label).to eq ['Test Place']
      expect(subject.point).to eq '1.0000 2.0000'
    end
  end
end
