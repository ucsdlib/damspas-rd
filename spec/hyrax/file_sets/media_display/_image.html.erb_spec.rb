require 'rails_helper'

RSpec.describe "hyrax/file_sets/show.html.erb", type: :view do
  let(:file_set_document) do
    SolrDocument.new(id: 'p1',
                     has_model_ssim: ['FileSet'],
                     digest_ssim: ['rn:sha1:1927bcc7ecc1eaa14b21822c431530d58d2ab004'])
  end
  let(:ability) { double }
  let(:file_set_presenter) { FileSetPresenter.new(file_set_document, :ability) }

  context 'IIIF viewer' do
    let(:picture_tag) { '<picture><source media="openseadragon" src="p1.tif/info.json" /></picture>' }

    before do
      Rails.configuration.iiif_enabled = true
      stub_view
      allow(Hyrax.config).to receive(:download_path).and_return('/downloads/p1')
      allow(view).to receive(:image_tag).and_return('<image src="/downloads/p1?file=thumbnail">')
      allow(view).to receive(:hyrax).and_return(Hyrax.config)
      render partial: "hyrax/file_sets/media_display/image", locals: { file_set: file_set_presenter }
    end

    it 'has hover trigger' do
      expect(rendered).to have_selector("a[class='hover_trigger']")
      expect(rendered).to have_content('/downloads/p1?file=thumbnail')
    end
  end

  context 'generic viewer' do
    before do
      Rails.configuration.iiif_enabled = false
      stub_view
      allow(Hyrax.config).to receive(:download_path).and_return('/downloads/p1')
      allow(view).to receive(:image_tag).and_return('<image src="/downloads/p1?file=thumbnail">')
      allow(view).to receive(:hyrax).and_return(Hyrax.config)
      render partial: "hyrax/file_sets/media_display/image", locals: { file_set: file_set_presenter }
    end

    it 'show image source url' do
      expect(rendered).to have_content('/downloads/p1?file=thumbnail')
    end
  end
end
