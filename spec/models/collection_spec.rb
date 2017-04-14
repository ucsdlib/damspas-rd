require 'rails_helper'

describe Collection do
  let(:creator) { UcsdAgent.create( label: 'Test Creator', agent_type:'Person' ) }
  let(:creator_a) { UcsdAgent.create( label: 'Creator A', agent_type:'Person' ) }
  let(:creator_b) { UcsdAgent.create( label: 'Creator B', agent_type:'Person' ) }
  let(:contributor) { UcsdAgent.create( label: 'Test Contributor', agent_type:'Organization' ) }
  let(:publisher) { UcsdAgent.create( label: 'Test Publisher', agent_type:'Organization' ) }
  let(:topic) { Concept.create( label: 'Test Topic' ) }
  let(:col) { described_class.new(title: ['Test Collection'], description: ['Test Description Text']) }
  let(:cre_col) { described_class.new(title: ['Test Collection'], creator: [creator.uri], contributor: [contributor.uri]) }
  let(:id_col) { described_class.new(title: ['Test Collection - Local identifier'], local: 'local_id') }
  let(:pub_col) { described_class.new(title: ['Test Collection - Publisher'], creator: [creator_a.uri], publisher: [publisher.uri]) }
  let(:top_col) { described_class.new(title: ['Test Collection - Topic'], creator: [creator_b.uri], topic: [topic.uri]) }
  let(:brd_col) { described_class.new(title: ['Test Collection - Brief Description'], brief_description: "Test Brief Description") }
  let(:loc_col) { described_class.new(title: ['Test Collection - Location Of Originals'], physical_description: ["Test Location Of Originals"]) }
  let(:lan_col) { described_class.new(title: ['Test Collection - Language'], language: ["http://lexvo.org/id/iso639-3/eng"]) }
  let(:lan_err_col) { described_class.new(title: ['Test Collection - Language'], language: ["Not a url"]) }

  describe 'Collection' do

    it 'should create Collection' do
      col.save ({:validate => false})
      expect { col.save }.to_not raise_error
      expect(col.id).to be_truthy
      @col = described_class.find col.id
      expect(@col.title.first).to eq 'Test Collection'
      expect(@col.description.first).to eq 'Test Description Text'
    end

    it 'should create Collection with local identifier' do
      id_col.save ({:validate => false})
      expect { id_col.save }.to_not raise_error
      expect(id_col.id).to be_truthy
      @id_col = described_class.find id_col.id
      expect(@id_col.title.first).to eq 'Test Collection - Local identifier'
      expect(@id_col.local).to eq 'local_id'
    end

    it 'should customized term Brief Description' do
      brd_col.save ({:validate => false})
      expect { brd_col.save }.to_not raise_error
      expect(brd_col.id).to be_truthy
      @col = described_class.find brd_col.id
      expect(@col.title.first).to eq 'Test Collection - Brief Description'
      expect(@col.brief_description).to eq 'Test Brief Description'
    end

    it 'should has creator and contributor' do
      cre_col.save ({:validate => false})
      expect { cre_col.save }.to_not raise_error
      expect(cre_col.id).to be_truthy
      @col = described_class.find cre_col.id
      expect(@col.title.first).to eq 'Test Collection'
      expect(@col.creator.first.label).to eq 'Test Creator'
      expect(@col.contributor.first.label).to eq 'Test Contributor'
    end

    it 'should has publisher' do
      pub_col.save ({:validate => false})
      expect { pub_col.save }.to_not raise_error
      expect(pub_col.id).to be_truthy
      @col = described_class.find pub_col.id
      expect(@col.title.first).to eq 'Test Collection - Publisher'
      expect(@col.creator.first.label).to eq 'Creator A'
      expect(@col.publisher.first.label).to eq 'Test Publisher'
    end

    it 'should has topic' do
      top_col.save ({:validate => false})
      expect { top_col.save }.to_not raise_error

      expect(top_col.id).to be_truthy
      @col = described_class.find top_col.id
      expect(@col.title.first).to eq 'Test Collection - Topic'
      expect(@col.creator.first.label).to eq 'Creator B'
      expect(@col.topic.first.label).to eq 'Test Topic'
    end

    it 'should contains Location Of Originals' do
      loc_col.save ({:validate => false})
      expect { loc_col.save }.to_not raise_error
      expect(loc_col.id).to be_truthy
      @col = described_class.find loc_col.id
      expect(@col.title.first).to eq 'Test Collection - Location Of Originals'
      expect(@col.physical_description.first).to eq 'Test Location Of Originals'
    end

    it 'should throw validation error with invalid URL for language' do
      lan_err_col.save
      expect { lan_err_col.save! }.to raise_error Exception
    end

    it 'should has language url' do
      lan_col.save ({:validate => false})
      expect { lan_col.save }.to_not raise_error
      expect(lan_col.id).to be_truthy
      @col = described_class.find lan_col.id
      expect(@col.title.first).to eq 'Test Collection - Language'
      expect(@col.language).to eq ['http://lexvo.org/id/iso639-3/eng']
    end

  end

  context 'with related resource' do
    let(:attributes) {{ title: ['Test Collection'], related_resource_attributes: [{related_type: ['relation'], name: ['Name'], url:['http://test.com/related/resource']}] }}
    let(:col) { described_class.new()}

    describe 'create related resource' do
      it 'should create nested related resource record' do
        col.attributes = attributes
        col.save({:validate => false})
        expect { col.save }.to_not raise_error
        expect(col.id).to be_truthy
        @col = described_class.find col.id
        expect(@col.title.first).to eq 'Test Collection'
        expect(@col.related_resource.first.name).to eq ['Name']
        expect(@col.related_resource.first.url).to eq ['http://test.com/related/resource']
      end
    end

    describe 'update related resource' do
      let(:attrs_updated) {{ title: ['Test Collection'], related_resource_attributes: [{related_type: ['relation'], name: ['Name updated'], url:['http://test.com/related/resource/updated']}] }}
      it 'should update nested related resource record' do
        col.attributes = attrs_updated
        col.save({:validate => false})
        expect { col.save }.to_not raise_error
        expect(col.id).to be_truthy
        @col = described_class.find col.id
        expect(@col.title.first).to eq 'Test Collection'
        expect(@col.related_resource.first.name).to eq ['Name updated']
        expect(@col.related_resource.first.url).to eq ['http://test.com/related/resource/updated']
      end
    end
  end
end
