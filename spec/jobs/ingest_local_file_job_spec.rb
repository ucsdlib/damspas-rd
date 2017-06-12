require 'spec_helper'

describe IngestLocalFileJob do
  let(:user) { create(:user) }

  let(:file_set) { FileSet.new }
  let(:actor) { double }

  let(:mock_upload_directory) { 'spec/mock_upload_directory' }

  before do
    Dir.mkdir mock_upload_directory unless File.exist? mock_upload_directory
    FileUtils.copy(File.expand_path('../../fixtures/files/file_1.jpg', __FILE__), mock_upload_directory)
    allow(Hyrax::Actors::FileSetActor).to receive(:new).with(file_set, user).and_return(actor)
  end

  after do
    FileUtils.rm_rf mock_upload_directory
  end

  it 'does not delete server side source file after ingest' do
    expect(actor).to receive(:create_content).and_return(true)
    described_class.perform_now(file_set, File.open(mock_upload_directory + '/file_1.jpg'), user)
    expect(File.exist?(File.open(mock_upload_directory + '/file_1.jpg'))).to be_truthy
  end
end
