require 'spec_helper'

describe AuthorityAttributeRenderer do
  let(:field) { :exact_match }
  let(:renderer) { described_class.new(field, ['Authority Exact Match'], {:uri => {'Authority Exact Match' => 'http://test.com/exact/match/url'}}) }

  describe "#attribute_to_html" do
    context 'authority label with links' do
      subject { renderer.render }
      let(:expected) do
        "<tr><th>Exact match</th>\n" \
        "<td><ul class='tabular'><li class=\"attribute exact_match\"><a href=\"http://test.com/exact/match/url\">Authority Exact Match</a></li></ul></td></tr>"
      end

      it "should have the authority link" do
        expect(subject).to eq expected
      end
    end
  end
end
