require 'rails_helper'

describe DownloadsController do
  describe '#show' do
    let(:user) { FactoryGirl.create(:admin) }
    let(:file_set) do
      FactoryGirl.create(:file_set, user: user, content: File.open(fixture_path + '/files/image.jpg'))
    end

    context "when the user has access" do
      before { sign_in user }

      it 'sends the original file' do
        get :show, :id => file_set.id
        expect(response.body).to eq file_set.original_file.content
      end

      it 'sends the thumbnail' do
        get :show, :id => file_set.id, :file => 'thumbnail'
        expect(response.body).not_to eq file_set.original_file.content
      end
    end
  end
end
