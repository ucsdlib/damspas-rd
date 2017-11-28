# Generated via
#  `rails generate hyrax:work ObjectResource`
require 'rails_helper'
require 'redlock'

RSpec.describe Hyrax::Actors::ObjectResourceActor do
  include ActionDispatch::TestProcess

  let(:user) { create(:admin) }
  let(:file_path) { File.join(fixture_path, 'image.jpg') }
  let(:file) { Rack::Test::UploadedFile.new(file_path, 'image/jpeg', false) }
  # stub out redis connection
  let(:redlock_client_stub) do
    client = double('redlock client')
    allow(client).to receive(:lock).and_yield(true)
    allow(Redlock::Client).to receive(:new).and_return(client)
    client
  end

  subject do
    Hyrax::CurationConcern.actor
  end

  describe '#nested attributes' do
    let(:curation_concern) { create(:object_resource, user: user) }

    context 'create nested attributes' do
      let(:attributes) do
        { title: ['Test Object'], visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
          related_resource_attributes: { "0" => { related_type: ['relation'], name: ['Related resource name'],
                                                  url: ['http://test.com/any/url'] } },
          identifier: ' ', license: ['http://creativecommons.org/licenses/by/3.0/us/'] }
      end
      let(:env) { Hyrax::Actors::Environment.new(curation_concern, Ability.new(user), attributes) }

      it 'creates nested related resource' do
        subject.update(env)
        expect(curation_concern.related_resource.count).to eq 1
        expect(curation_concern.related_resource.first.related_type).to eq ['relation']
        expect(curation_concern.related_resource.first.name).to eq ['Related resource name']
        expect(curation_concern.related_resource.first.url).to eq ['http://test.com/any/url']
      end

      it 'removes empty property' do
        expect(curation_concern.identifier).to be nil
      end
    end

    context 'update nested attributes' do
      let(:attributes) do
        { title: ['Test Object Updated'], visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
          related_resource_attributes: { "0" => { related_type: ['relation'], name: ['Related resource name updated'],
                                                  url: ['http://test.com/any/url'] } },
          identifier: ' ', license: ['http://creativecommons.org/licenses/by/3.0/us/'] }
      end
      let(:env) { Hyrax::Actors::Environment.new(curation_concern, Ability.new(user), attributes) }

      it 'updates the nested related resource' do
        subject.update(env)
        expect(curation_concern.related_resource.count).to eq 1
        expect(curation_concern.related_resource.first.related_type).to eq ['relation']
        expect(curation_concern.related_resource.first.name).to eq ['Related resource name updated']
        expect(curation_concern.related_resource.first.url).to eq ['http://test.com/any/url']
      end
    end
  end
end
