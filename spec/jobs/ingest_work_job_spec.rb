describe IngestWorkJob do
  let(:user) { create(:user) }
  let(:log) { create(:batch_create_operation, user: user) }

  before do
    allow(Hyrax.config.callback).to receive(:run)
    allow(Hyrax.config.callback).to receive(:set?)
      .with(:after_batch_create_success)
      .and_return(true)
    allow(Hyrax.config.callback).to receive(:set?)
      .with(:after_batch_create_failure)
      .and_return(true)
  end

  describe "#perform" do
    let(:model) { 'ObjectResource' }
    let(:components) { [{title: ['Test Object One'], level: 'Object'}, {title: ['Test Component One'], level: 'Component'}, {title: ['Test Sub-component One'], level: 'Sub-component'}] }
    let(:errors) { double(full_messages: "It's broke!") }
    let(:work) { double(errors: errors) }
    let(:actor) { double(curation_concern: work) }

    subject do
      described_class.perform_later(user,
                                    model,
                                    components,
                                    log)
    end

    it "ingest complex object metadata" do
      expect(Hyrax::CurationConcern).to receive(:actor).exactly(3).times.and_return(actor)
        expect(actor).to receive(:create).with( Hyrax::Actors::Environment) do |env|
          expect(env.attributes).to include(title: ['Test Object One'])
        end.and_return(true)
        expect(actor).to receive(:create).with( Hyrax::Actors::Environment) do |env|
          expect(env.attributes).to include(title: ['Test Component One'])
        end.and_return(true)
        expect(actor).to receive(:create).with( Hyrax::Actors::Environment) do |env|
          expect(env.attributes).to include(title: ['Test Sub-component One'])
        end.and_return(true)
      expect(Hyrax.config.callback).to receive(:run).with(:after_batch_create_success, user)
      subject
      expect(log.status).to eq 'pending'
      expect(log.reload.status).to eq 'success'
    end
  end
end
