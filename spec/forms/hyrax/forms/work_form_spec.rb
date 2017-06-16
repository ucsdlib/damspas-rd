RSpec.describe Hyrax::Forms::WorkForm do
  let(:work) { ObjectResource.new }
  let(:form) { described_class.new(work, nil, nil) }
  let(:works) { [ObjectResource.new, FileSet.new, ObjectResource.new] }

  # This class is an abstract class, so we have to set model_class
  # TODO: merge with generic_work_form_spec
  before do
    allow(described_class).to receive(:model_class).and_return(ObjectResource)
    allow(form).to receive(:model_class).and_return(ObjectResource)
  end

  describe "#version" do
    before do
      allow(work).to receive(:etag).and_return('123456')
    end

    subject { form.version }

    it { is_expected.to eq '123456' }
  end

  describe "#select_files" do
    let(:work) { create(:object_resource_with_file) }
    let(:title) { work.file_sets.first.title.first }
    let(:file_id) { work.file_sets.first.id }

    subject { form.select_files }

    it { is_expected.to eq(title => file_id) }
  end

  describe "#[]" do
    it 'has one element' do
      expect(form['description']).to eq ['']
    end
  end

  describe "#work_members" do
    subject { form.work_members }

    before do
      allow(work).to receive(:members).and_return(works)
    end

    it "expects members that are works" do
      expect(form.work_members.size).to eq(2)
    end
  end

  describe ".build_permitted_params" do
    subject { described_class.build_permitted_params }

    context "without mediated deposit" do
      it {
        is_expected.to include({ permissions_attributes: [:type, :name, :access, :id, :_destroy] },
                               work_members_attributes: [:id, :_destroy],
                               based_near_attributes: [:id, :_destroy])
      }
    end
  end

  describe ".model_attributes" do
    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        title: ['foo'],
        description: [''],
        visibility: 'open',
        parent_id: '123',
        representative_id: '456',
        thumbnail_id: '789',
        rights_statement: 'http://rightsstatements.org/vocab/InC-EDU/1.0/',
        license: ['http://creativecommons.org/licenses/by/3.0/us/']
      }
    end

    subject { described_class.model_attributes(params) }

    it 'permits parameters' do
      expect(subject['title']).to eq ['foo']
      expect(subject['description']).to be_empty
      expect(subject['visibility']).to eq 'open'
      expect(subject['license']).to eq ['http://creativecommons.org/licenses/by/3.0/us/']
      expect(subject['rights_statement']).to eq 'http://rightsstatements.org/vocab/InC-EDU/1.0/'
    end

    it 'excludes non-permitted params' do
      expect(subject).not_to have_key 'parent_id'
    end

    context "when a user is granted edit access" do
      let(:admin_set) { create(:admin_set) }

      context "and a admin_set that allows grants has been selected" do
        let(:attributes) do
          { admin_set_id: admin_set.id, permissions_attributes: [{ type: 'person', name: 'justin', access: 'edit' }] }
        end
        let(:permission_template) { create(:permission_template, admin_set_id: admin_set.id) }
        let!(:workflow) do
          create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id)
        end
        let(:expected_params) do
          ActionController::Parameters.new(admin_set_id: admin_set.id,
                                           permissions_attributes: [ActionController::Parameters.new(type: 'person',
                                                                                                     name: 'justin',
                                                                                                     access: 'edit')])
        end

        it do
          is_expected.to eq expected_params.permit!
        end
      end

      context "and no admin_set has been selected" do
        let(:attributes) { { permissions_attributes: [{ type: 'person', name: 'justin', access: 'edit' }] } }

        it { is_expected.to eq ActionController::Parameters.new.permit! }
      end

      context "and an admin_set that doesn't allow grants has been selected" do
        let(:attributes) do
          { admin_set_id: admin_set.id,
            permissions_attributes: [{ type: 'person', name: 'justin', access: 'edit' }] }
        end
        let(:permission_template) { create(:permission_template, admin_set_id: admin_set.id) }
        let!(:workflow) do
          create(:workflow, allows_access_grant: false, active: true, permission_template_id: permission_template.id)
        end

        it { is_expected.to eq ActionController::Parameters.new(admin_set_id: admin_set.id).permit! }
      end
    end

    context "without permissions being set" do
      let(:attributes) { {} }

      it { is_expected.to eq ActionController::Parameters.new.permit! }
    end
  end

  describe "initialized fields" do
    context "for :description" do
      subject { form[:description] }

      it { is_expected.to eq [''] }
    end

    context "for :embargo_release_date" do
      subject { form[:embargo_release_date] }

      it { is_expected.to be nil }
    end

    context "for :related_resource_attributes" do
      let(:work) do
        ObjectResource.new(title: ["Related resource"],
                           related_resource_attributes: [{ related_type: ['relation'],
                                                           name: ['Name'],
                                                           url: ['http://test.com/related'] }])
      end
      let(:form) { described_class.new(work, nil, nil) }

      subject { form[:related_resource].first }

      it { expect(subject.related_type).to eq ['relation'] }
      it { expect(subject.name).to eq ['Name'] }
      it { expect(subject.url).to eq ['http://test.com/related'] }
    end
  end

  describe '#visibility' do
    subject { form.visibility }

    it { is_expected.to eq 'restricted' }
  end

  describe '#human_readable_type' do
    subject { form.human_readable_type }

    it { is_expected.to eq 'Object' }
  end

  describe "#open_access?" do
    subject { form.open_access? }

    it { is_expected.to be false }
  end

  describe "#authenticated_only_access?" do
    subject { form.authenticated_only_access? }

    it { is_expected.to be false }
  end

  describe "#open_access_with_embargo_release_date?" do
    subject { form.open_access_with_embargo_release_date? }

    it { is_expected.to be false }
  end

  describe "#private_access?" do
    subject { form.private_access? }

    it { is_expected.to be true }
  end

  describe "#member_ids" do
    subject { form.member_ids }

    it { is_expected.to eq work.member_ids }
  end

  describe '#display_additional_fields?' do
    subject { form.display_additional_fields? }

    context 'with no secondary terms' do
      before do
        allow(form).to receive(:secondary_terms).and_return([])
      end

      it { is_expected.to be false }
    end

    context 'with secondary terms' do
      before do
        allow(form).to receive(:secondary_terms).and_return([:foo, :bar])
      end

      it { is_expected.to be true }
    end
  end

  describe "#embargo_release_date" do
    let(:work) { create(:object_resource, embargo_release_date: 5.days.from_now) }

    subject { form.embargo_release_date }

    it { is_expected.to eq work.embargo_release_date }
  end

  describe "#lease_expiration_date" do
    let(:work) { create(:object_resource, lease_expiration_date: 2.days.from_now) }

    subject { form.lease_expiration_date }

    it { is_expected.to eq work.lease_expiration_date }
  end

  describe ".workflow_for" do
    subject { described_class.send(:workflow_for, admin_set_id: admin_set.id) }

    context "when a active workflow is not found" do
      let(:admin_set) { create(:admin_set, with_permission_template: true) }

      it "raises a custom error" do
        expect { subject }.to raise_error Hyrax::MissingWorkflowError
      end
    end

    context "when a permission_template is not found" do
      let(:admin_set) { create(:admin_set) }

      it "raises an error" do
        expect { subject }.to raise_error(/Missing permission template for AdminSet\(id:/)
      end
    end
  end
end
