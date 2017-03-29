require "rails_helper"

describe AuthoritiesService do
  describe "UCSD Agent" do
    before do
      @auth = UcsdAgent.create(label: 'UCSD Agent', agent_type: 'Person')
      @auth_alt = UcsdAgent.create(label: 'UCSD Agent', alternate_label: 'Alternate label', agent_type: 'Person')
      @auth_2 = UcsdAgent.create(label: 'UCSD Agent 2', alternate_label: 'Alternate label', agent_type: 'Person')
    end

    after do
      @auth.delete
      @auth_alt.delete
      @auth_2.delete
    end

    describe "find all agents" do
      subject { described_class.find_all_agents }
      it "includes all the agents" do
        expect(subject.count).to eq 3
        expect(subject.select { |agent| agent[0] == 'UCSD Agent' }.count).to eq 2
        expect(subject.select { |agent| agent[0] == 'UCSD Agent 2' }.count).to eq 1
      end
    end

    describe "find agents by label" do
      subject { described_class.find_agents 'UCSD Agent' }
      it "includes only agents with label 'UCSD Agent'" do
        expect(subject.count).to eq 2
        expect(subject.select { |agent| agent if agent.label == 'UCSD Agent' }.count).to eq 2
      end
    end

    describe "find agents by label and alternate label" do
      subject { described_class.find_agents 'UCSD Agent', 'Alternate label' }
      it "includes only agent with lable 'UCSD Agent' and alternate_label 'Alternate label'" do
        expect(subject.count).to eq 1
        expect(subject.select { |agent| agent if agent.id == @auth_alt.id }.count).to eq 1
      end
    end
  end

  describe "Place" do
    before do
      @auth = Place.create(label: 'Test Place')
      @auth_alt = Place.create(label: 'Test Place Alternate', alternate_label: 'Alternate label')
    end

    after do
      @auth.delete
      @auth_alt.delete
    end

    describe "find all Place" do
      subject { described_class.find_all_places }
      it "includes all the places" do
        expect(subject.count).to eq 2
      end
    end
  end

  describe 'Concept' do
    before do
      @auth = Concept.create(label: 'Test Concept')
      @auth_alt = Concept.create(label: 'Test Concept Alternate', alternate_label: 'Alternate label')
    end

    after do
      @auth.delete
      @auth_alt.delete
    end

    describe "find all Concept" do
      subject { described_class.find_all_subjects }
      it "includes all the concepts" do
        expect(subject.count).to eq 2
      end
    end
  end

  describe 'find or create' do
    context '#UcsdAgent' do
      before do
        @auth = UcsdAgent.create(label: 'UCSD Agent', agent_type: 'Person')
      end
      after do
        @auth.delete
      end

      context '#find' do
        let(:expected) { described_class.find_agents(@auth.label).first }
        subject { described_class.find_or_create 'UcsdAgent', @auth.label }
        it "existing UcsdAgent" do
          expect(subject.id).to eq expected.id
        end
      end

      context '#create' do
        let(:expected) { described_class.find_agents("New #{@auth.label}").first }
        subject { described_class.find_or_create 'UcsdAgent', "New #{@auth.label}", '', 'Person' }
        it "new UcsdAgent" do
          expect(expected).to be nil
          expect(subject.id).not_to be nil
        end
      end
    end
  end
end