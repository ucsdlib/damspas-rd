require "rails_helper"

describe LanguageSelectService do
  before do
    @language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
    @lang_auth = Qa::LocalAuthority.find_or_create_by(name: 'languages')
    @lang = ::Qa::LocalAuthorityEntry.create(
        local_authority: @lang_auth,
        label: 'Language',
        uri: @language_uri)
  end

  after do
    @lang.delete
  end

  describe "language" do
    context 'get uri by label' do
      let(:subject) { described_class.new.get_uri 'Language'}

      it 'should get the uri' do
        expect(subject).not_to be nil
        expect(subject.to_s).to eq @language_uri
      end
    end

    context 'get label by uri' do
      let(:subject) { described_class.new.get_label @language_uri}

      it 'should get the label' do
        expect(subject).not_to be nil
        expect(subject.to_s).to eq 'Language'
      end
    end
  end
end