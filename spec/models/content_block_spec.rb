RSpec.describe ContentBlock, type: :model do
  let!(:bilbo) do
    create(:content_block,
           name: ContentBlock::NAME_REGISTRY[:researcher],
           value: '<h1>Bilbo Baggins</h1>',
           created_at: Time.zone.now)
  end

  let!(:marketing) do
    create(:content_block,
           name: ContentBlock::NAME_REGISTRY[:marketing],
           value: '<h1>Marketing Text</h1>')
  end

  let!(:announcement) do
    create(:content_block,
           name: ContentBlock::NAME_REGISTRY[:announcement],
           value: '<h1>Announcement Text</h1>')
  end

  describe '.for' do
    context 'with a nil' do
      it 'raises an ArgumentError' do
        expect { described_class.for(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'with a non-whitelisted value' do
      it 'raises an ArgumentError' do
        expect { described_class.for(:destroy_all) }.to raise_error(ArgumentError)
      end
    end

    context 'with a whitelisted value as a symbol' do
      subject { described_class.for(:about) }

      it 'returns a new instance' do
        expect(described_class).to receive(:about_page).and_call_original
        expect(subject).to be_instance_of ContentBlock
        expect(subject).to be_persisted
      end
    end
  end

  describe '.announcement_text' do
    subject { described_class.for(:announcement).value }

    it { is_expected.to eq '<h1>Announcement Text</h1>' }
  end

  describe '.announcement_text=' do
    let(:new_announcement) { '<h2>Foobar</h2>' }

    it 'sets a new announcement_text' do
      described_class.announcement_text = new_announcement
      expect(described_class.for(:announcement).value).to eq new_announcement
    end
  end

  describe '.marketing_text' do
    subject { described_class.for(:marketing).value }

    it { is_expected.to eq '<h1>Marketing Text</h1>' }
  end

  describe '.marketing_text=' do
    let(:new_marketing) { '<h2>Barbaz</h2>' }

    it 'sets a new marketing_text' do
      described_class.marketing_text = new_marketing
      expect(described_class.for(:marketing).value).to eq new_marketing
    end
  end

  describe '.featured_researcher' do
    subject { described_class.for(:researcher) }

    it 'returns entry for featured_researcher' do
      expect(subject).to eq bilbo
    end
  end

  describe '.featured_researcher=' do
    let(:new_researcher) { '<h2>Baz Quux</h2>' }

    it 'adds a new featured researcher' do
      described_class.featured_researcher = new_researcher
      expect(described_class.for(:researcher).value).to eq new_researcher
    end
  end

  describe '.agreement_page' do
    before do
      allow(ApplicationController).to receive(:helpers).and_return(helper_module)
    end

    let(:helper_module) do
      double('helpers',
             application_name: 'TheBest',
             institution_name: 'Foo E D U',
             institution_name_full: 'Foolhardy Edutainment')
    end

    subject { described_class.for(:agreement) }

    it 'defaults to text loaded from a template' do
      expect(subject.value).to include 'TheBest Deposit Agreement'
    end
  end

  describe '.agreement_page=' do
    let(:new_agreement) { '<h2>Quuuuuuuuuux</h2>' }

    it 'changes the agreement page value' do
      described_class.agreement_page = new_agreement
      expect(described_class.for(:agreement).value).to eq new_agreement
    end
  end

  describe '.terms_page' do
    before do
      allow(ApplicationController).to receive(:helpers).and_return(helper_module)
    end

    let(:helper_module) do
      double('helpers',
             application_name: 'TheBest',
             institution_name: 'Foo E D U',
             institution_name_full: 'Foolhardy Edutainment')
    end

    subject { described_class.for(:terms) }

    it 'defaults to text loaded from a template' do
      expect(subject.value).to include 'Terms of Use for TheBest'
    end
  end

  describe '.terms_page=' do
    let(:new_terms) { '<h2>Fooooooob</h2>' }

    it 'changes the terms page value' do
      described_class.terms_page = new_terms
      expect(described_class.for(:terms).value).to eq new_terms
    end
  end

  context "the about page" do
    before do
      create(:content_block,
             name: ContentBlock::NAME_REGISTRY[:about],
             value: '<h1>About Page</h1>')
    end

    describe 'getter' do
      subject { described_class.for(:about).value }

      it { is_expected.to eq '<h1>About Page</h1>' }
    end

    describe 'setter' do
      let(:new_about) { '<h2>Foobarfoo</h2>' }

      it 'sets a new about_page' do
        described_class.about_page = new_about
        expect(described_class.for(:about).value).to eq new_about
      end
    end
  end

  context "the help page" do
    before do
      create(:content_block,
             name: ContentBlock::NAME_REGISTRY[:help],
             value: '<h1>Help Page</h1>')
    end

    describe 'getter' do
      subject { described_class.for(:help).value }

      it { is_expected.to eq '<h1>Help Page</h1>' }
    end

    describe 'setter' do
      let(:new_help) { '<h2>Foobarfoo</h2>' }

      it 'sets a new help_page' do
        described_class.help_page = new_help
        expect(described_class.for(:help).value).to eq new_help
      end
    end
  end

  context "the faq page" do
    before do
      create(:content_block,
             name: ContentBlock::NAME_REGISTRY[:faq],
             value: '<h1>FAQ Page</h1>')
    end

    describe 'getter' do
      subject { described_class.for(:faq).value }

      it { is_expected.to eq '<h1>FAQ Page</h1>' }
    end

    describe 'setter' do
      let(:new_faq) { '<h2>faqfoo</h2>' }

      it 'sets a new faq_page' do
        described_class.faq_page = new_faq
        expect(described_class.for(:faq).value).to eq new_faq
      end
    end
  end

  context "the takedown page" do
    before do
      create(:content_block,
             name: ContentBlock::NAME_REGISTRY[:takedown],
             value: '<h1>Take Down Page</h1>')
    end

    describe 'getter' do
      subject { described_class.for(:takedown).value }

      it { is_expected.to eq '<h1>Take Down Page</h1>' }
    end

    describe 'setter' do
      let(:new_takedown) { '<h2>takedownfoo</h2>' }

      it 'sets a new takedown_page' do
        described_class.takedown_page = new_takedown
        expect(described_class.for(:takedown).value).to eq new_takedown
      end
    end
  end

  context "the search_tips page" do
    before do
      create(:content_block,
             name: ContentBlock::NAME_REGISTRY[:search_tips],
             value: '<h1>Search Tips Page</h1>')
    end

    describe 'getter' do
      subject { described_class.for(:search_tips).value }

      it { is_expected.to eq '<h1>Search Tips Page</h1>' }
    end

    describe 'setter' do
      let(:new_search_tips) { '<h2>search_tipsfoo</h2>' }

      it 'sets a new search_tips_page' do
        described_class.search_tips_page = new_search_tips
        expect(described_class.for(:search_tips).value).to eq new_search_tips
      end
    end
  end
end
