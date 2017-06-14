require 'rails_helper'

describe Collection do
  let(:creator) { UcsdAgent.create(label: 'Test Creator', agent_type: 'Person') }
  let(:creator_a) { UcsdAgent.create(label: 'Creator A', agent_type: 'Person') }
  let(:creator_b) { UcsdAgent.create(label: 'Creator B', agent_type: 'Person') }
  let(:contributor) { UcsdAgent.create(label: 'Test Contributor', agent_type: 'Organization') }
  let(:publisher) { UcsdAgent.create(label: 'Test Publisher', agent_type: 'Organization') }
  let(:topic) { Concept.create(label: 'Test Topic') }
  let(:col) { described_class.new(title: ['Test Collection'], description: ['Test Description Text']) }
  let(:cre_col) do
    described_class.new(title: ['Test Collection'], creator: [creator.uri], contributor: [contributor.uri])
  end
  let(:id_col) { described_class.new(title: ['Test Collection - Local identifier'], local: 'local_id') }
  let(:pub_col) do
    described_class.new(title: ['Test Collection - Publisher'], creator: [creator_a.uri], publisher: [publisher.uri])
  end
  let(:top_col) do
    described_class.new(title: ['Test Collection - Topic'], creator: [creator_b.uri], topic: [topic.uri])
  end
  let(:brd_col) do
    described_class.new(title: ['Test Collection - Brief Description'], brief_description: "Test Brief Description")
  end
  let(:loc_col) do
    described_class.new(title: ['Test Collection - Location Of Originals'],
                        physical_description: ["Test Location Of Originals"])
  end
  let(:lan_col) do
    described_class.new(title: ['Test Collection - Language'], language: ["http://lexvo.org/id/iso639-3/eng"])
  end
  let(:lan_err_col) { described_class.new(title: ['Test Collection - Language'], language: ["Not a url"]) }

  describe 'Collection' do
    it 'creates Collection' do
      col.save(validate: false)
      expect { col.save }.not_to raise_error
      expect(col.id).to be_truthy
      @col = described_class.find col.id
      expect(@col.title.first).to eq 'Test Collection'
      expect(@col.description.first).to eq 'Test Description Text'
    end

    it 'creates Collection with local identifier' do
      id_col.save(validate: false)
      expect { id_col.save }.not_to raise_error
      expect(id_col.id).to be_truthy
      @id_col = described_class.find id_col.id
      expect(@id_col.title.first).to eq 'Test Collection - Local identifier'
      expect(@id_col.local).to eq 'local_id'
    end

    it 'customizeds term Brief Description' do
      brd_col.save(validate: false)
      expect { brd_col.save }.not_to raise_error
      expect(brd_col.id).to be_truthy
      @col = described_class.find brd_col.id
      expect(@col.title.first).to eq 'Test Collection - Brief Description'
      expect(@col.brief_description).to eq 'Test Brief Description'
    end

    it 'hases creator and contributor' do
      cre_col.save(validate: false)
      expect { cre_col.save }.not_to raise_error
      expect(cre_col.id).to be_truthy
      @col = described_class.find cre_col.id
      expect(@col.title.first).to eq 'Test Collection'
      expect(@col.creator.first.label).to eq 'Test Creator'
      expect(@col.contributor.first.label).to eq 'Test Contributor'
    end

    it 'hases publisher' do
      pub_col.save(validate: false)
      expect { pub_col.save }.not_to raise_error
      expect(pub_col.id).to be_truthy
      @col = described_class.find pub_col.id
      expect(@col.title.first).to eq 'Test Collection - Publisher'
      expect(@col.creator.first.label).to eq 'Creator A'
      expect(@col.publisher.first.label).to eq 'Test Publisher'
    end

    it 'hases topic' do
      top_col.save(validate: false)
      expect { top_col.save }.not_to raise_error

      expect(top_col.id).to be_truthy
      @col = described_class.find top_col.id
      expect(@col.title.first).to eq 'Test Collection - Topic'
      expect(@col.creator.first.label).to eq 'Creator B'
      expect(@col.topic.first.label).to eq 'Test Topic'
    end

    it 'containses Location Of Originals' do
      loc_col.save(validate: false)
      expect { loc_col.save }.not_to raise_error
      expect(loc_col.id).to be_truthy
      @col = described_class.find loc_col.id
      expect(@col.title.first).to eq 'Test Collection - Location Of Originals'
      expect(@col.physical_description.first).to eq 'Test Location Of Originals'
    end

    it 'throws validation error with invalid URL for language' do
      lan_err_col.save
      expect { lan_err_col.save! }.to raise_error Exception
    end

    it 'hases language url' do
      lan_col.save(validate: false)
      expect { lan_col.save }.not_to raise_error
      expect(lan_col.id).to be_truthy
      @col = described_class.find lan_col.id
      expect(@col.title.first).to eq 'Test Collection - Language'
      expect(@col.language).to eq ['http://lexvo.org/id/iso639-3/eng']
    end
  end

  context 'with related resource' do
    let(:attributes) do
      { title: ['Test Collection'],
        related_resource_attributes: [{ related_type: ['relation'],
                                        name: ['Name'],
                                        url: ['http://test.com/related/resource'] }] }
    end
    let(:col) { described_class.new }

    describe 'create related resource' do
      it 'creates nested related resource record' do
        col.attributes = attributes
        col.save(validate: false)
        expect { col.save }.not_to raise_error
        expect(col.id).to be_truthy
        @col = described_class.find col.id
        expect(@col.title.first).to eq 'Test Collection'
        expect(@col.related_resource.first.name).to eq ['Name']
        expect(@col.related_resource.first.url).to eq ['http://test.com/related/resource']
      end
    end

    describe 'update related resource' do
      let(:attrs_updated) do
        { title: ['Test Collection'],
          related_resource_attributes: [{ related_type: ['relation'],
                                          name: ['Name updated'],
                                          url: ['http://test.com/related/resource/updated'] }] }
      end

      it 'updates nested related resource record' do
        col.attributes = attrs_updated
        col.save(validate: false)
        expect { col.save }.not_to raise_error
        expect(col.id).to be_truthy
        @col = described_class.find col.id
        expect(@col.title.first).to eq 'Test Collection'
        expect(@col.related_resource.first.name).to eq ['Name updated']
        expect(@col.related_resource.first.url).to eq ['http://test.com/related/resource/updated']
      end
    end
  end
end
