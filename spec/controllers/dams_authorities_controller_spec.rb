describe DamsAuthoritiesController do
  let(:user) { create(:editor) }

  before do
    sign_in user
    @ucsd_agent = UcsdAgent.create(label: 'Test UCSD Agent Label', agent_type: 'Person')
  end

  after do
   @ucsd_agent.delete
  end

  describe "#show" do
    it "is successful" do
      get :show, params: {authority: 'ucsd_agent', id: @ucsd_agent.id}
      expect(response).to be_successful
      expect(response).to render_template("show")
    end
  end
end
