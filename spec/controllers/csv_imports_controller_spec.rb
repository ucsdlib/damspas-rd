describe CsvImportsController do
  let(:user) { create(:editor) }
  let(:csv_source) { Rack::Test::UploadedFile.new(File.open(fixture_path + '/csv_import_test.csv')) }
  let(:file1) { File.open(fixture_path + '/file_1.jpg') }
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
      expect(assigns[:form]).to be_kind_of CsvImportForm
    end
  end

  describe "#create" do
    context "enquing a update job" do
      it "is successful" do
        parameters = {
          csv_source: csv_source,
          uploaded_files: [upload1.id.to_s],
          selected_files: {},
          csv_import_item: {visibility: 'open'}
        }
        post :create, params: parameters
        expect(response).to redirect_to Hyrax::Engine.routes.url_helpers.dashboard_works_path
        expect(flash[:notice]).to include("Your files are being processed by Hyrax in the background.")
      end
    end
  end

  describe "attributes_for_actor" do
    subject { controller.send(:attributes_for_actor) }

    before do
      controller.params = { csv_source: csv_source,
                            uploaded_files: [upload1.id.to_s],
                            selected_files: {},
                            csv_import_item: { visibility: 'open' } }
    end
    let(:expected_params) do
      if Rails.version < '5.0.0'
        { 'visibility' => 'open' }
      else
        ActionController::Parameters.new(visibility: 'open').permit!
      end
    end
    it "excludes uploaded_files" do
      expect(subject).to eq expected_params
    end
  end
end
