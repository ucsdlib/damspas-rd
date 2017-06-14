require 'rails_helper'

describe Agent do
  describe 'create' do
    let(:subject) { described_class.new(label: 'Test Agent', alternate_label: 'Alternate label') }

    it 'has a label and alternate label' do
      expect(subject.label).to eq 'Test Agent'
      expect(subject.alternate_label).to eq 'Alternate label'
    end
  end
end
