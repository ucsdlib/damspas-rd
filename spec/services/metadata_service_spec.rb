require "rails_helper"

describe 'MetadataService' do
  describe "Languages" do
    before do
      language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
      @lang_auth = Qa::LocalAuthority.find_or_create_by(name: 'languages')
      @lang = ::Qa::LocalAuthorityEntry.create(
          local_authority: @lang_auth,
          label: 'Language',
          uri: language_uri)
    end

    after do
      @lang.delete
    end

    describe "find all languages" do
      subject { MetadataService.find_all_languages.select { |lang| lang[0] == 'Language' }.count }
      it { is_expected.to eq 1 }
    end
  end

  describe "find_all_resource_type" do
    subject { MetadataService.find_all_resource_types.count }
    it { is_expected.to be > 0 }
  end

  describe "find_all_local_attributions" do
    subject { MetadataService.local_attribution_list.count }
    it { is_expected.to be > 0 }
  end
end