require "rails_helper"

describe MetadataService do
  describe "Languages" do
    before do
      language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
      @lang_auth = Qa::LocalAuthority.find_or_create_by(name: 'languages')
      @lang = ::Qa::LocalAuthorityEntry.create(
        local_authority: @lang_auth,
        label: 'Language',
        uri: language_uri
      )
    end

    after do
      @lang.delete
    end

    describe "find all languages" do
      subject { described_class.find_all_languages.select { |lang| lang[0] == 'Language' }.count }

      it { is_expected.to eq 1 }
    end
  end

  describe "Country Codes" do
    before do
      @country_code_auth = Qa::LocalAuthority.find_or_create_by(name: 'country_codes')
      @country_code = ::Qa::LocalAuthorityEntry.create(
        local_authority: @country_code_auth,
        label: 'Country Name',
        uri: 'CODE'
      )
    end

    after do
      @country_code.delete
    end

    describe "find all country codes" do
      subject do
        described_class.find_all_country_codes.select { |country_code| country_code[0] == 'Country Name' }.count
      end

      it { is_expected.to eq 1 }
    end
  end

  describe "find_all_copyright_status" do
    subject { described_class.find_all_copyright_status.count }

    it { is_expected.to be > 0 }
  end

  describe "find_all_resource_type" do
    subject { described_class.find_all_resource_types.count }

    it { is_expected.to be > 0 }
  end

  describe "find_all_local_attributions" do
    subject { described_class.local_attribution_list.count }

    it { is_expected.to be > 0 }
  end

  describe "find_all_related_resource_types" do
    subject { described_class.find_all_related_resource_types.count }

    it { is_expected.to be > 0 }
  end
end
