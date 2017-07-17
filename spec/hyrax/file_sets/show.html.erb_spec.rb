RSpec.describe 'hyrax/file_sets/show.html.erb', type: :view do
  let(:user) { double(user_key: 'sarah', twitter_handle: 'test') }
  let(:file_set) do
    build(:file_set, id: '123', depositor: user.user_key, title: ['My Title'], user: user, visibility: 'open')
  end
  let(:ability) { double }
  let(:solr_doc) { SolrDocument.new(file_set.to_solr) }
  let(:presenter) { Hyrax::FileSetPresenter.new(solr_doc, ability) }
  let(:mock_metadata) do
    {
      format: ["Tape"],
      long_term: ["x" * 255],
      multi_term: ["1", "2", "3", "4", "5", "6", "7", "8"],
      string_term: 'oops, I used a string instead of an array',
      logged_fixity_status: "Fixity checks have not yet been run on this file"
    }.to_h
  end

  before do
    view.lookup_context.prefixes.push 'hyrax/base'
    allow(view).to receive(:can?).with(:edit, SolrDocument).and_return(false)
    allow(ability).to receive(:can?).with(:edit, SolrDocument).and_return(false)
    allow(presenter).to receive(:fixity_status).and_return(mock_metadata)
    assign(:presenter, presenter)
    assign(:document, solr_doc)
    assign(:fixity_status, "none")
    allow(FileSet).to receive(:find).with('123').and_return(file_set)
  end

  describe 'title heading' do
    before do
      stub_template 'shared/_title_bar.html.erb' => 'Title Bar'
      stub_template 'shared/_citations.html.erb' => 'Citation'
      render
    end
    it 'shows the title' do
      expect(rendered).to have_selector 'h1', text: 'My Title'
    end
  end

  it "does not render single-use links" do
    expect(rendered).not_to have_selector('table.single-use-links')
  end

  describe 'preservation_master_file' do
    let(:files_json) do
      ["{\"file_use\":\"preservation_master_file\", \"file_name\":\"image.jpg\"}",
       "{\"file_use\":\"original_file\"}"]
    end
    let(:file_set_document) { SolrDocument.new(id: "123", has_model_ssim: ["FileSet"], files_json_tesim: files_json) }
    let(:file_set_presenter) { FileSetPresenter.new(file_set_document, ability) }

    before do
      allow(view).to receive(:can?).with(:create, ObjectResource).and_return(true)
      allow(presenter).to receive(:fixity_status).and_return(mock_metadata)
      assign(:presenter, file_set_presenter)
      assign(:document, file_set_document)
      render
    end

    it 'show the download link' do
      expect(rendered).to have_content('image.jpg')
      expect(rendered).to have_link('Download', href: "#{hyrax.download_path(presenter)}&file=preservation_master_file")
    end
  end
end
