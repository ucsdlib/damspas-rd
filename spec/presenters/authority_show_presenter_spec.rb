describe AuthorityShowPresenter do

  let(:linked_authority) {UcsdAgent.create(label: 'Linked Authority Show Presenter Test', agent_type: 'Person')}
  let(:authority) {UcsdAgent.new(label: 'Authority Show Presenter Test', alternate_label: 'Alternate label', agent_type: 'Person', exact_match: [linked_authority.uri.to_s] )}
  let(:ability) { double }
  let(:presenter) { described_class.new(solr_doc, ability) }
  let(:solr_doc) { SolrDocument.new(authority.to_solr) }

  after do
    linked_authority.delete
  end

  describe ".terms" do
    subject { described_class.terms }
    it do
      is_expected.to eq [:agent_type, :label, :alternate_label, :has_orcid, :exact_match, 
         :close_match, :related_match, :different_from, :note, :point]
    end
  end

  subject { presenter }
  it { expect(presenter.label).to eq 'Authority Show Presenter Test' }
  it { expect(presenter.alternate_label).to eq 'Alternate label' }
  it { expect(presenter.agent_type).to eq 'Person' }
  it { expect(presenter.exact_match).to eq 'Linked Authority Show Presenter Test' }

  it "finds the renderer class by it class name" do
    expect(presenter.find_renderer_class 'AuthorityAttributeRenderer').to eq AuthorityAttributeRenderer
  end
end