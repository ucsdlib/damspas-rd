describe BatchImportController do
  let(:user) { create(:editor) }
  let(:source_metadata) {}
  let(:file1) { File.open(fixture_path + '/files/file_1.jpg') }
  let(:upload1) { Hyrax::UploadedFile.create(user: user, file: file1) }
  let(:metadata) { {} }
  let(:uploaded_files) { [upload1.id.to_s] }
  let(:selected_files) { [] }
  let(:expected_params) { {'visibility' => 'open'} }

  before do
    sign_in user
  end

  describe "#new" do
    it "is successful" do
      get :new
      expect(response).to be_successful
      expect(assigns[:form]).to be_kind_of BatchImportForm
    end
  end

  context "Excel XL metadata source" do
    let(:source_metadata) { Rack::Test::UploadedFile.new(File.open(fixture_path + '/imports/excel_xl_import_test.xlsx')) }
    describe "#create" do
      context "enquing a update job" do
        it "is successful" do
          parameters = {
            source_metadata: source_metadata,
            uploaded_files: [upload1.id.to_s],
            selected_files: {},
            batch_import_item: {visibility: 'open'}
          }
          post :create, params: parameters
          expect(response).to redirect_to "#{Hyrax::Engine.routes.url_helpers.dashboard_works_path}?locale=en"
          expect(flash[:notice]).to include("Your files are being processed by Hyrax in the background.")
        end
      end
    end

    describe "attributes_for_actor" do
      subject { controller.send(:attributes_for_actor) }

      before do
        controller.params = { source_metadata: source_metadata,
                              uploaded_files: [upload1.id.to_s],
                              selected_files: {},
                              batch_import_item: { visibility: 'open' } }
      end
      let(:expected_params) do
        ActionController::Parameters.new(visibility: 'open', "remote_files"=>[], "uploaded_files"=>["1"]).permit!
      end
      it "excludes uploaded_files" do
        expect(subject).to eq expected_params
      end
    end
  end

  context "CSV metadata source" do
    let(:source_metadata) { Rack::Test::UploadedFile.new(File.open(fixture_path + '/imports/csv_import_test.csv')) }
    describe "#create" do
      context "enquing a update job" do
        it "is successful" do
          parameters = {
            source_metadata: source_metadata,
            uploaded_files: [upload1.id.to_s],
            selected_files: {},
            batch_import_item: {visibility: 'open'}
          }
          post :create, params: parameters
          expect(response).to redirect_to "#{Hyrax::Engine.routes.url_helpers.dashboard_works_path}?locale=en"
          expect(flash[:notice]).to include("Your files are being processed by Hyrax in the background.")
        end
      end
    end

    describe "attributes_for_actor" do
      subject { controller.send(:attributes_for_actor) }

      before do
        controller.params = { source_metadata: source_metadata,
                              uploaded_files: [upload1.id.to_s],
                              selected_files: {},
                              batch_import_item: { visibility: 'open' } }
      end
      let(:expected_params) do
        ActionController::Parameters.new(visibility: 'open', "remote_files"=>[], "uploaded_files"=>["1"]).permit!
      end
      it "excludes uploaded_files" do
        expect(subject).to eq expected_params
      end
    end
  end
end
