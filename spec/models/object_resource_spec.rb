# Generated via
#  `rails generate hyrax:work ObjectResource`
require 'rails_helper'

describe ObjectResource do
  let(:creator) { UcsdAgent.create(label: 'Object Creator', agent_type: 'Person') }
  let(:creator_a) { UcsdAgent.create(label: 'Object Creator A', agent_type: 'Person') }
  let(:creator_b) { UcsdAgent.create(label: 'Object Creator B', agent_type: 'Person') }
  let(:contributor) { UcsdAgent.create(label: 'Object Contributor', agent_type: 'Organization') }
  let(:publisher) { UcsdAgent.create(label: 'Object Publisher', agent_type: 'Organization') }
  let(:topic) { Concept.create(label: 'Object Topic') }
  let(:obj) { described_class.new(title: ['Test Object Resource'], description: ['Test Description Text']) }
  let(:cre_obj) do
    described_class.new(title: ['Test Object Resource'], creator: [creator.uri], contributor: [contributor.uri])
  end
  let(:id_obj) { described_class.new(title: ['Test Object Resource - Local identifier'], local: 'local_id') }
  let(:pub_obj) do
    described_class.new(title: ['Test Object Resource - Publisher'],
                        creator: [creator_a.uri], publisher: [publisher.uri])
  end
  let(:top_obj) do
    described_class.new(title: ['Test Object Resource - Topic'], creator: [creator_b.uri], topic: [topic.uri])
  end
  let(:phd_obj) do
    described_class.new(title: ['Test Object Resource - Physical Description'],
                        physical_description: ["Test physical description"])
  end
  let(:lan_obj) do
    described_class.new(title: ['Test Object Resource - Language'], language: ["http://lexvo.org/id/iso639-3/eng"])
  end
  let(:lan_err_obj) { described_class.new(title: ['Test Object Resource - Language'], language: ["Not a url"]) }

  context 'ObjectResource create/edit' do
    it 'creates object resource' do
      obj.save(validate: false)
      expect { obj.save }.not_to raise_error
      expect(obj.id).to be_truthy
      @obj = described_class.find obj.id
      expect(@obj.title.first).to eq 'Test Object Resource'
      expect(@obj.description.first).to eq 'Test Description Text'
    end

    it 'creates object resource with local identifier' do
      id_obj.save(validate: false)
      expect { id_obj.save }.not_to raise_error
      expect(id_obj.id).to be_truthy
      @id_obj = described_class.find id_obj.id
      expect(@id_obj.title.first).to eq 'Test Object Resource - Local identifier'
      expect(@id_obj.local).to eq 'local_id'
    end

    it 'hases creator and contributor' do
      cre_obj.save(validate: false)
      expect { cre_obj.save }.not_to raise_error
      expect(cre_obj.id).to be_truthy
      @obj = described_class.find cre_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource'
      expect(@obj.creator.first.label).to eq 'Object Creator'
      expect(@obj.contributor.first.label).to eq 'Object Contributor'
    end

    it 'hases publisher' do
      pub_obj.save(validate: false)
      expect { pub_obj.save }.not_to raise_error
      expect(pub_obj.id).to be_truthy
      @obj = described_class.find pub_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Publisher'
      expect(@obj.creator.first.label).to eq 'Object Creator A'
      expect(@obj.publisher.first.label).to eq 'Object Publisher'
    end

    it 'has topic' do
      top_obj.save(validate: false)
      expect { top_obj.save }.not_to raise_error

      expect(top_obj.id).to be_truthy
      @obj = described_class.find top_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Topic'
      expect(@obj.creator.first.label).to eq 'Object Creator B'
      expect(@obj.topic.first.label).to eq 'Object Topic'
    end

    it 'has physical description' do
      phd_obj.save(validate: false)
      expect { phd_obj.save }.not_to raise_error
      expect(phd_obj.id).to be_truthy
      @obj = described_class.find phd_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Physical Description'
      expect(@obj.physical_description.first).to eq 'Test physical description'
    end

    it 'throws validation error with invalid URL for language' do
      lan_err_obj.save
      expect { lan_err_obj.save! }.to raise_error Exception
    end

    it 'hases language url' do
      lan_obj.save(validate: false)
      expect { lan_obj.save }.not_to raise_error
      expect(lan_obj.id).to be_truthy
      @obj = described_class.find lan_obj.id
      expect(@obj.title.first).to eq 'Test Object Resource - Language'
      expect(@obj.language).to eq ['http://lexvo.org/id/iso639-3/eng']
    end
  end

  context 'Create new ObjectResource with default NOID' do
    before do
      @enable_noids = Hyrax.config.enable_noids?
      Hyrax.config.enable_noids = true
    end

    after do
      Hyrax.config.enable_noids = @enable_noids
    end

    let(:noid_template) { Noid::Template.new Hyrax.config.noid_template }

    it 'matches NOID pattern' do
      obj.save(validate: false)
      expect { obj.save }.not_to raise_error
      expect(obj.id).to be_truthy
      expect(noid_template.valid?(obj.id)).to be_truthy
    end
  end

  context 'Create new ObjectResource with AF::NOID disabled that use Fedora UUID' do
    before do
      @enable_noids = Hyrax.config.enable_noids?
      Hyrax.config.enable_noids = false
    end

    after do
      Hyrax.config.enable_noids = @enable_noids
    end

    let(:noid_template) { Noid::Template.new Hyrax.config.noid_template }
    let(:uuid_pattern) { '[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}' }

    it 'does not match NOID pattern' do
      obj.save(validate: false)
      expect { obj.save }.not_to raise_error
      expect(obj.id).to be_truthy
      expect(noid_template.valid?(obj.id)).not_to be_truthy
      expect(obj.id.match(uuid_pattern)).to be_truthy
    end
  end

  context 'with nested attributes' do
    let(:attributes) do
      { title: ['Test Object Resource'],
        related_resource_attributes: [{ related_type: ['relation'],
                                        name: ['Name'],
                                        url: ['http://test.com/related/resource'] }] }
    end
    let(:obj) { described_class.new }

    describe 'create related resource' do
      it 'creates nested related resource record' do
        obj.attributes = attributes
        obj.save(validate: false)
        expect { obj.save }.not_to raise_error
        expect(obj.id).to be_truthy
        @obj = described_class.find obj.id
        expect(@obj.title.first).to eq 'Test Object Resource'
        expect(@obj.related_resource.first.name).to eq ['Name']
        expect(@obj.related_resource.first.url).to eq ['http://test.com/related/resource']
      end
    end

    describe 'update related resource' do
      let(:attrs_updated) do
        { title: ['Test Object Resource'],
          related_resource_attributes: [{ related_type: ['relation'],
                                          name: ['Name updated'],
                                          url: ['http://test.com/related/resource/updated'] }] }
      end

      it 'updates nested related resource record' do
        obj.attributes = attrs_updated
        obj.save(validate: false)
        expect { obj.save }.not_to raise_error
        expect(obj.id).to be_truthy
        @obj = described_class.find obj.id
        expect(@obj.title.first).to eq 'Test Object Resource'
        expect(@obj.related_resource.first.name).to eq ['Name updated']
        expect(@obj.related_resource.first.url).to eq ['http://test.com/related/resource/updated']
      end
    end
  end
end
