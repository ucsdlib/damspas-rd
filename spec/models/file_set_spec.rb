require 'rails_helper'

describe FileSet do
  let!(:admin_user) { FactoryGirl.create(:admin) }

  describe 'should persist derivatives on Fedora' do
    describe 'with a video' do
      let!(:file_set) { FactoryGirl.create(:file_set, title: ["Video"], :user => admin_user) }
      before do
        Hydra::Works::AddFileToFileSet.call(file_set, File.open("#{fixture_path}/files/video.mp4", 'rb'), :original_file, update_existing: true)
      end
      it 'makes a service file' do
        file_set.create_service_file
        expect(file_set.service_file).not_to be nil
        expect(file_set.service_file.uri.to_s).to include(ActiveFedora.fedora.host)
      end
    end
    describe 'with an audio' do
      let!(:file_set) { FactoryGirl.create(:file_set, title: ["Audio"], :user => admin_user) }
      before do
        Hydra::Works::AddFileToFileSet.call(file_set, File.open("#{fixture_path}/files/audio.wav", 'rb'), :original_file, update_existing: true)
      end
      it 'makes a service file' do
        file_set.create_service_file
        expect(file_set.service_file).not_to be nil
        expect(file_set.service_file.uri.to_s).to include(ActiveFedora.fedora.host)
      end
    end
  end
end
