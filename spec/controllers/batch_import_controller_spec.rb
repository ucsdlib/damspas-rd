include Warden::Test::Helpers

describe BatchImportController do
  let(:user) { create(:editor) }
  let(:source_metadata) {}
  let(:file1) { File.open(fixture_path + '/files/file_1.jpg') }
  let(:upload1) { Hyrax::UploadedFile.create(user: user, file: file1) }
  let(:metadata) { {} }
  let(:uploaded_files) { [upload1.id.to_s] }
  let(:selected_files) { [] }
  let(:expected_params) { { 'visibility' => 'open', :model => 'ObjectResource' } }
  let(:parameters) do
    {
      source_metadata: source_metadata,
      uploaded_files: [upload1.id.to_s],
      selected_files: {},
      batch_import_item: { visibility: 'open', payload_concern: 'ObjectResource' }
    }
  end

  before do
    login_with user
  end

  describe "#new" do
    it "is successful" do
      get :new
      expect(response).to be_successful
      expect(assigns[:form]).to be_kind_of BatchImportForm
    end
  end

  context "Excel XL metadata source" do
    let(:file) { File.open(fixture_path + '/imports/excel_xl_import_test.xlsx') }
    let(:source_metadata) { Rack::Test::UploadedFile.new(file) }

    describe "#create" do
      context 'when feature is disabled' do
        before do
          allow(Flipflop).to receive(:batch_upload?).and_return(false)
        end
        it 'redirects with an error message' do
          post :create, params: parameters.merge(format: :html)
          expect(response).to redirect_to Hyrax::Engine.routes.url_helpers.my_works_path(locale: 'en')
          expect(flash[:alert]).to include('Feature disabled by administrator')
        end
        context 'when json is requested' do
          it 'returns an HTTP 403' do
            post :create, params: parameters.merge(format: :json)
            expect(response).to have_http_status(403)
            expect(response.body).to include('Feature disabled by administrator')
          end
        end
      end

      context "enqueue an update job" do
        it "is successful" do
          post :create, params: parameters
          expect(response).to redirect_to "#{Hyrax::Engine.routes.url_helpers.dashboard_works_path}?locale=en"
          expect(flash[:notice]).to include("Your files are being processed by Hyrax in the background.")
        end
      end
    end

    describe "attributes_for_actor" do
      subject { controller.send(:attributes_for_actor) }

      before do
        controller.params = parameters
      end

      let(:expected_params) do
        ActionController::Parameters.new(visibility: 'open', "remote_files" => [], "uploaded_files" => ["1"]).permit!
      end

      it "excludes uploaded_files" do
        expect(subject).to eq expected_params
      end
    end
  end

  context "CSV metadata source" do
    let(:source_metadata) { Rack::Test::UploadedFile.new(File.open(fixture_path + '/imports/csv_import_test.csv')) }

    describe "#create" do
      context "enqueue an update job" do
        it "is successful" do
          post :create, params: parameters
          expect(response).to redirect_to "#{Hyrax::Engine.routes.url_helpers.dashboard_works_path}?locale=en"
          expect(flash[:notice]).to include("Your files are being processed by Hyrax in the background.")
        end
      end
    end

    describe "attributes_for_actor" do
      subject { controller.send(:attributes_for_actor) }

      before do
        controller.params = parameters
      end
      let(:expected_params) do
        ActionController::Parameters.new(visibility: 'open', "remote_files" => [], "uploaded_files" => ["1"]).permit!
      end

      it "excludes uploaded_files" do
        expect(subject).to eq expected_params
      end
    end
  end
end
