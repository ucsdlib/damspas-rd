# Generated via
#  `rails generate curation_concerns:work ObjectResource`
require 'rails_helper'

describe ObjectResource do
  let(:creator) { Agent.create( label: ['Object Creator'] ) }
  let(:creator_a) { Agent.create( label: ['Object Creator A'] ) }
  let(:creator_b) { Agent.create( label: ['Object Creator B'] ) }
  let(:contributor) { Agent.create( label: ['Object Contributor'] ) }
  let(:publisher) { Agent.create( label: ['Object Publisher'] ) }
  let(:topic) { Concept.create( label: ['Object Topic'] ) }
  let(:obj) { described_class.new(title: ['Test Object Resource'], description:  ['Test Description Text']) }
  let(:cre_obj) { described_class.new(title: ['Test Object Resource'], creator: [creator.uri], contributor: [contributor.uri]) }
  let(:pub_obj) { described_class.new(title: ['Test Object Resource - Publisher'], creator: [creator_a.uri], publisher: [publisher.uri]) }
  let(:top_obj) { described_class.new(title: ['Test Object Resource - Topic'], creator: [creator_b.uri], topic: [topic.uri]) }
  let(:phd_obj) { described_class.new(title: ['Test Object Resource - Physical Description'], physical_description: ["Test physical description"]) }
  let(:lan_obj) { described_class.new(title: ['Test Object Resource - Language'], language: ["http://lexvo.org/id/iso639-3/eng"]) }
  let(:lan_err_obj) { described_class.new(title: ['Test Object Resource - Language'], language: ["Not a url"]) }

  describe 'Object Resource' do

    it 'should create object resource' do
      obj.save ({:validate => false})
      expect { obj.save }.to_not raise_error
      expect(obj.id).to be_truthy
      @obj = described_class.find obj.id
      expect(@obj.title.first).to eq 'Test Object Resource'
      expect(@obj.description.first).to eq 'Test Description Text'
    end
 
    it 'should has creator and contributor' do
      cre_obj.save ({:validate => false})
      expect { cre_obj.save }.to_not raise_error
      expect(cre_obj.id).to be_truthy
      @obj = described_class.find cre_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource'
      expect(@obj.creator.first.label.first).to eq 'Object Creator'
      expect(@obj.contributor.first.label.first).to eq 'Object Contributor'
    end

    it 'should has publisher' do
      pub_obj.save ({:validate => false})
      expect { pub_obj.save }.to_not raise_error
      expect(pub_obj.id).to be_truthy
      @obj = described_class.find pub_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Publisher'
      expect(@obj.creator.first.label.first).to eq 'Object Creator A'
      expect(@obj.publisher.first.label.first).to eq 'Object Publisher'
    end

    it 'should has topic' do
      top_obj.save ({:validate => false})
      expect { top_obj.save }.to_not raise_error

      expect(top_obj.id).to be_truthy
      @obj = described_class.find top_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Topic'
      expect(@obj.creator.first.label.first).to eq 'Object Creator B'
      expect(@obj.topic.first.label.first).to eq 'Object Topic'
    end

    it 'should has topic' do
      phd_obj.save ({:validate => false})
      expect { phd_obj.save }.to_not raise_error
      expect(phd_obj.id).to be_truthy
      @obj = described_class.find phd_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Physical Description'
      expect(@obj.physical_description.first).to eq 'Test physical description'
    end

    it 'should throw validation error with invalid URL for language' do
      lan_err_obj.save
      expect { lan_err_obj.save! }.to raise_error Exception
    end

    it 'should has language url' do
      lan_obj.save ({:validate => false})
      expect { lan_obj.save }.to_not raise_error
      expect(lan_obj.id).to be_truthy
      @obj = described_class.find lan_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Language'
      expect(@obj.language).to eq ['http://lexvo.org/id/iso639-3/eng']
    end
  end
end
