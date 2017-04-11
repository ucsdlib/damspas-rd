describe 'BatchImportJob' do
  let(:user) { create(:user) }
  let(:log) { create(:batch_create_operation, user: user) }

  before do
    allow(CharacterizeJob).to receive(:perform_later)
    allow(Hyrax.config.callback).to receive(:run)
    allow(Hyrax.config.callback).to receive(:set?)
      .with(:after_batch_create_success)
      .and_return(true)
    allow(Hyrax.config.callback).to receive(:set?)
      .with(:after_batch_create_failure)
      .and_return(true)
  end

  describe "#perform" do
    let(:source_metadata) {}
    let(:template) { File.join(Rails.root, 'imports', 'object_import_template.xlsx') }
    let(:file1) { File.open(fixture_path + '/files/file_1.jpg') }
    let(:upload1) { Hyrax::UploadedFile.create(user: user, file: file1) }
    let(:metadata) { {} }
    let(:uploaded_files) { [upload1.id.to_s] }
    let(:selected_files) { [] }
    let(:errors) { double(full_messages: "It's broke!") }
    let(:work) { double(errors: errors) }
    let(:actor) { double(curation_concern: work) }

    subject do
      BatchImportJob.perform_later(user,
                                    source_metadata,
                                    uploaded_files,
                                    selected_files,
                                    metadata,
                                    template,
                                    log)
    end

    context "Excel XL metadata source" do
      let(:source_metadata) { File.join(fixture_path, 'imports', '/excel_xl_import_test.xlsx') }
      it "updates work metadata" do
        expect(Hyrax::CurationConcern).to receive(:actor).exactly(3).times.and_return(actor)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Object One'])).and_return(true)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Component One'], uploaded_files: [upload1.id.to_s])).and_return(true)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Sub-component One'])).and_return(true)
        expect(Hyrax.config.callback).to receive(:run).with(:after_batch_create_success, user)
        subject
        expect(log.status).to eq 'pending'
        expect(log.reload.status).to eq 'success'
      end

      context "when permissions_attributes are passed" do
        let(:metadata) do
          { "permissions_attributes" => [{ "type" => "group", "name" => "public", "access" => "read" }] }
        end
        it "sets the groups" do
          subject
          work = ObjectResource.last
          expect(work.read_groups).to include "public"
        end
      end

      context "when visibility is passed" do
        let(:metadata) do
          { "visibility" => "open" }
        end
        it "sets public read access" do
          subject
          work = ObjectResource.last
          expect(work.reload.read_groups).to eq ['public']
        end
      end

      context "when user does not have permission to edit all of the works" do
        it "sends the failure message" do
          expect(Hyrax::CurationConcern).to receive(:actor).exactly(3).times.and_return(actor)
          expect(actor).to receive(:create).exactly(3).times.and_return(false)
          expect(Hyrax.config.callback).to receive(:run).with(:after_batch_create_failure, user)
          subject
          expect(log.reload.status).to eq 'failure'
        end
      end
    end

    context "CSV metadata source" do
      let(:source_metadata) { File.join(fixture_path, 'imports', '/csv_import_test.csv') }

      it "updates work metadata" do
        expect(Hyrax::CurationConcern).to receive(:actor).exactly(3).times.and_return(actor)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Object One'])).and_return(true)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Component One'], uploaded_files: [upload1.id.to_s])).and_return(true)
        expect(actor).to receive(:create).with( hash_including(title: ['Test Sub-component One'])).and_return(true)
        expect(Hyrax.config.callback).to receive(:run).with(:after_batch_create_success, user)
        subject
        expect(log.status).to eq 'pending'
        expect(log.reload.status).to eq 'success'
      end
    end
  end
end
