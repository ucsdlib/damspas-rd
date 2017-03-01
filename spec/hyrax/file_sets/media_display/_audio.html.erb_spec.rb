require 'rails_helper'

RSpec.describe "hyrax/file_sets/show.html.erb", type: :view do
  let(:file_set_document) { SolrDocument.new(id: 'p1', has_model_ssim: ['FileSet']) }
  let(:file_set_presenter) { FileSetPresenter.new(file_set_document, nil) }

  before do
    @wowza_enabled = Rails.configuration.wowza_enabled
  end

  after do
    Rails.configuration.wowza_enabled = @wowza_enabled
  end

  context 'streaming' do
    before do
      Rails.configuration.wowza_enabled = true
      stub_view
      allow(view).to receive(:wowza_url).and_return('wowza_url')
      render partial: "hyrax/file_sets/media_display/audio", locals: { file_set: file_set_presenter }
    end

    it 'show audio streaming url' do
      expect(rendered).to have_content('https://wowza_url/playlist.m3u8')
    end
  end

  context 'generic viewer' do
    before do
      Rails.configuration.wowza_enabled = false
      stub_view
      allow(Hyrax.config).to receive(:download_path).and_return('/downloads?file=mp3')
      allow(view).to receive(:hyrax).and_return(Hyrax.config)
      render partial: "hyrax/file_sets/media_display/audio", locals: { file_set: file_set_presenter }
    end

    it 'show audio source url' do
      expect(rendered).to have_selector("source[src='/downloads?file=mp3']")
    end
  end
end
