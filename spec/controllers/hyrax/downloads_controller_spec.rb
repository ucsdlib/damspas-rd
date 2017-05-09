require 'spec_helper'

RSpec.describe Hyrax::DownloadsController do
  routes { Hyrax::Engine.routes }

  describe '#show' do
    let(:user) { FactoryGirl.create(:user) }
    let(:file_set) do
      FactoryGirl.create(:file_with_work, user: user, content: File.open(fixture_path + '/files/image.jpg'))
    end
    let(:default_image) { ActionController::Base.helpers.image_path 'default.png' }

    context "when user doesn't have access" do
      let(:another_user) { FactoryGirl.create(:user) }
      before { sign_in another_user }

      it 'redirects to the default image' do
        get :show, params: { id: file_set.to_param }
        expect(response).to redirect_to default_image
      end
    end

    context "when user isn't logged in" do
      it 'redirects to the default image' do
        get :show, params: { id: file_set.to_param }
        expect(response).to redirect_to default_image
      end

      it 'authorizes the resource using only the id' do
        expect(controller).to receive(:authorize!).with(:read, file_set.id)
        get :show, params: { id: file_set.to_param }
      end
    end

    context "when the user has access" do
      before { sign_in user }

      it 'sends the original file' do
        get :show, params: { id: file_set }
        expect(response.body).to eq file_set.original_file.content
      end

      context "with an alternative file" do
        context "that is persisted" do
          let(:file) { File.open(fixture_path + '/files/world.png', 'rb') }
          let(:content) { file.read }

          before do
            allow(Hyrax::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/files/world.png')
          end

          it 'sends requested file content' do
            get :show, params: { id: file_set, file: 'thumbnail' }
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "4218"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end

          it 'retrieves the thumbnail without contacting Fedora' do
            expect(ActiveFedora::Base).not_to receive(:find).with(file_set.id)
            get :show, params: { id: file_set, file: 'thumbnail' }
          end
        end
      end
    end

    context 'metadata-only and culturally-sensitive object resources' do
      let(:admin_user) { FactoryGirl.create(:admin) }
      let!(:metadata_only_object_resource) { FactoryGirl.create(:metadata_only_object_resource_with_files, title: ["Metadata-only Object Title"], user: admin_user) }

      context 'anonymous user' do
        let(:dc_not_available_icon) { ActionController::Base.helpers.image_path 'dc_not_available.jpg' }

        it 'redirects to dc_not_available icon' do
          get :show, params: { id: metadata_only_object_resource.file_sets.first, file: 'thumbnail' }
          expect(response).to redirect_to dc_not_available_icon
        end
      end

      context "a authorized use" do
        before do
          sign_in admin_user
          allow(Hyrax::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/files/world.png')
        end
        let(:content) { File.open(fixture_path + '/files/world.png', 'rb').read }

        it 'sends requested file content' do
          get :show, params: { id: metadata_only_object_resource.file_sets.first, file: 'thumbnail' }
          expect(response.body).to eq content
        end
      end
    end

    context 'culturally-sensitive object resources' do
      let(:admin_user) { FactoryGirl.create(:admin) }
      let!(:culturally_sensitive_object_resource) { FactoryGirl.create(:culturally_sensitive_object_resource_with_files, title: ["Culturally-sensitive Object Title"], user: admin_user) }

      context 'anonymous user' do
        let(:content) { File.open(Rails.root.join("app", "assets", "images", 'thumb-restricted.png'), 'rb').read }

        it 'sends the icon' do
          get :show, params: { id: culturally_sensitive_object_resource.file_sets.first, file: 'thumbnail' }
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq content
        end
      end

      context "a authorized use" do
        before do
          sign_in admin_user
          allow(Hyrax::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/files/image.jpg')
        end
        let(:content) { File.open(fixture_path + '/files/image.jpg', 'rb').read }

        it 'sends requested file content' do
          get :show, params: { id: culturally_sensitive_object_resource.file_sets.first, file: 'thumbnail' }
          expect(response.body).to eq content
        end
      end
    end
  end

  describe "derivative_download_options" do
    before do
      allow(controller).to receive(:default_file).and_return 'world.png'
    end
    subject { controller.send(:derivative_download_options) }
    it { is_expected.to eq(disposition: 'inline', type: 'image/png') }
  end
end
