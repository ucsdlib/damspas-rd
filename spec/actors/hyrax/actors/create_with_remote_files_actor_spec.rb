RSpec.describe Hyrax::Actors::CreateWithRemoteFilesActor do
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:actor) { stack.build(terminator) }
  let(:stack) do
    ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
  end
  let(:user) { create(:user) }
  let(:ability) { Ability.new(user) }
  let(:work) { create(:object_resource, user: user) }
  let(:url1) { "https://dl.dropbox.com/fake/blah-blah.filepicker-demo.txt.txt" }
  let(:url2) { "https://dl.dropbox.com/fake/blah-blah.Getting%20Started.pdf" }
  let(:file) { "file:///local/file/here.txt" }

  let(:remote_files) do
    [{ url: url1,
       expires: "2014-03-31T20:37:36.214Z",
       file_name: "filepicker-demo.txt.txt" },
     { url: url2,
       expires: "2014-03-31T20:37:36.731Z",
       file_name: "Getting+Started.pdf" }]
  end
  let(:file_uses) { ['original_file'] }
  let(:attributes) { { remote_files: remote_files, file_use: file_uses } }
  let(:environment) { Hyrax::Actors::Environment.new(work, ability, attributes) }

  before do
    allow(terminator).to receive(:create).and_return(true)
  end

  context "with source uris that are remote" do
    let(:remote_files) do
      [{ url: url1,
         expires: "2014-03-31T20:37:36.214Z",
         file_name: "filepicker-demo.txt.txt" },
       { url: url2,
         expires: "2014-03-31T20:37:36.731Z",
         file_name: "Getting+Started.pdf" }]
    end
    let(:file_uses) { ["original_file", "preservation_master_file"] }

    it "attaches files" do
      expect(ImportUrlWithFileUseJob).to receive(:perform_later).with(FileSet,
                                                                      Hyrax::Operation,
                                                                      URI,
                                                                      "original_file")
      expect(ImportUrlWithFileUseJob).to receive(:perform_later).with(FileSet,
                                                                      Hyrax::Operation,
                                                                      URI,
                                                                      "preservation_master_file")
      expect(actor.create(environment)).to be true
    end
  end

  context "with source uris that are local files" do
    let(:remote_files) do
      [{ url: file,
         expires: "2014-03-31T20:37:36.214Z",
         file_name: "here.txt" }]
    end

    it "attaches files" do
      expect(IngestLocalFileJob).to receive(:perform_later).with(FileSet, "/local/file/here.txt",
                                                                 user, "original_file")
      expect(actor.create(environment)).to be true
    end

    context "with spaces" do
      let(:file) { "file:///local/file/ pigs .txt" }

      it "attaches files" do
        expect(IngestLocalFileJob).to receive(:perform_later).with(FileSet, "/local/file/ pigs .txt",
                                                                   user, "original_file")
        expect(actor.create(environment)).to be true
      end
    end

    context "attaches files with file use property" do
      let(:file_uses) { ['original_file'] }
      let(:attributes) { { remote_files: remote_files, file_use: file_uses } }

      it "attaches files" do
        expect(IngestLocalFileJob).to receive(:perform_later).with(FileSet, "/local/file/here.txt",
                                                                   user, file_uses.first)
        expect(actor.create(environment)).to be true
      end
    end
  end
end
