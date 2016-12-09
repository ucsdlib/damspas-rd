require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:public_object_resource) {
    FactoryGirl.build(:object_resource, user: admin_user)
  }

  let(:private_object_resource) {
    FactoryGirl.build(:private_object_resource, user: admin_user)
  }

  let(:campus_only_object_resource) {
    FactoryGirl.build(:campus_only_object_resource, user: admin_user)
  }

  let(:admin_file) { FactoryGirl.build(:file_set, user: admin_user) }

  let(:public_collection) {
    FactoryGirl.build(:collection, user: admin_user)
  }

  let(:campus_only_collection) {
    FactoryGirl.build(:campus_only_collection, user: admin_user)
  }

  let(:private_collection) {
    FactoryGirl.build(:private_collection, user: admin_user)
  }

  let(:admin_user) { FactoryGirl.create(:admin) }
  let(:editor) { FactoryGirl.create(:editor) }
  let(:curator) { FactoryGirl.create(:curator) }
  let(:campus_user) { FactoryGirl.create(:campus) }
  let(:role) { Role.where(name: 'admin').first_or_create }
  let(:solr) { ActiveFedora.solr.conn }

  before do
    allow(public_object_resource).to receive(:id).and_return("public")
    allow(campus_only_object_resource).to receive(:id).and_return("campus_only")
    allow(private_object_resource).to receive(:id).and_return("private")
    allow(admin_file).to receive(:id).and_return("admin_file")
    allow(public_collection).to receive(:id).and_return("public")
    allow(campus_only_collection).to receive(:id).and_return("campus_only")
    allow(private_collection).to receive(:id).and_return("private")
    [public_object_resource, private_object_resource, campus_only_object_resource, admin_file, public_collection, campus_only_collection, private_collection].each do |obj|
      allow(subject.cache).to receive(:get).with(obj.id).and_return(Hydra::PermissionsSolrDocument.new(obj.to_solr, nil))
    end
  end

  describe 'as an admin' do
    let(:current_user) { admin_user }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, campus_only_object_resource)
      should be_able_to(:read, private_object_resource)
      should be_able_to(:create, ObjectResource.new)
      should be_able_to(:create, FileSet.new)
      should be_able_to(:edit, public_object_resource)
      should be_able_to(:edit, campus_only_object_resource)
      should be_able_to(:edit, private_object_resource)
      should be_able_to(:update, public_object_resource)
      should be_able_to(:update, campus_only_object_resource)
      should be_able_to(:update, private_object_resource)
      should be_able_to(:destroy, public_object_resource)
      should be_able_to(:destroy, campus_only_object_resource)
      should be_able_to(:destroy, private_object_resource)
      should be_able_to(:destroy, admin_file)

      should be_able_to(:download, admin_file)
      should be_able_to(:file_manager, public_object_resource)

      should be_able_to(:create, Collection.new)
      should be_able_to(:read, public_collection)
      should be_able_to(:read, campus_only_collection)
      should be_able_to(:read, private_collection)
      should be_able_to(:edit, public_collection)
      should be_able_to(:edit, campus_only_collection)
      should be_able_to(:edit, private_collection)
      should be_able_to(:destroy, public_collection)
      should be_able_to(:destroy, campus_only_collection)
      should be_able_to(:destroy, private_collection)

      should be_able_to(:create, Role.new)
      should be_able_to(:destroy, Role)
    }
  end

  describe 'as an editor' do
    let(:current_user) { editor }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, campus_only_object_resource)
      should be_able_to(:read, private_object_resource)
      should be_able_to(:create, ObjectResource.new)
      should be_able_to(:create, FileSet.new)
      should be_able_to(:edit, public_object_resource)
      should be_able_to(:edit, campus_only_object_resource)
      should be_able_to(:edit, private_object_resource)
      should be_able_to(:update, public_object_resource)
      should be_able_to(:update, campus_only_object_resource)
      should be_able_to(:update, private_object_resource)
      should be_able_to(:destroy, public_object_resource)
      should be_able_to(:destroy, campus_only_object_resource)
      should be_able_to(:destroy, private_object_resource)
      should be_able_to(:destroy, admin_file)

      should be_able_to(:download, admin_file)
      should be_able_to(:file_manager, public_object_resource)

      should be_able_to(:create, Collection.new)
      should be_able_to(:read, public_collection)
      should be_able_to(:read, private_collection)
      should be_able_to(:edit, public_collection)
      should be_able_to(:edit, private_collection)
      should be_able_to(:destroy, public_collection)
      should be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
    }
  end

  describe 'as a curator' do
    let(:current_user) { curator }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, campus_only_object_resource)
      should be_able_to(:read, private_object_resource)
      should be_able_to(:download, admin_file)
      should be_able_to(:read, public_collection)
      should be_able_to(:read, campus_only_collection)
      should be_able_to(:read, private_collection)

      should_not be_able_to(:create, ObjectResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:file_manager, public_object_resource)
      should_not be_able_to(:edit, public_object_resource)
      should_not be_able_to(:update, public_object_resource)
      should_not be_able_to(:destroy, public_object_resource)
      should_not be_able_to(:destroy, admin_file)

      should_not be_able_to(:create, Collection.new)
      should_not be_able_to(:edit, public_collection)
      should_not be_able_to(:edit, campus_only_collection)
      should_not be_able_to(:edit, private_collection)
      should_not be_able_to(:destroy, public_collection)
      should_not be_able_to(:destroy, campus_only_collection)
      should_not be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
    }
  end

  describe 'as a campus user' do
    let(:current_user) { campus_user }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, campus_only_object_resource)
      should be_able_to(:read, public_collection)
      should be_able_to(:read, public_collection)
      should be_able_to(:read, campus_only_collection)

      should_not be_able_to(:read, private_object_resource)
      should_not be_able_to(:edit, public_object_resource)
      should_not be_able_to(:update, public_object_resource)
      should_not be_able_to(:create, ObjectResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, public_object_resource)
      should_not be_able_to(:destroy, admin_file)
      should_not be_able_to(:file_manager, public_object_resource)
      should_not be_able_to(:save_structure, public_object_resource)
      should_not be_able_to(:download, admin_file)
      should_not be_able_to(:read, private_collection)
      should_not be_able_to(:edit, public_collection)
      should_not be_able_to(:edit, private_collection)
      should_not be_able_to(:destroy, public_collection)
      should_not be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Collection.new)
      should_not be_able_to(:read, private_collection)
      should_not be_able_to(:edit, public_collection)
      should_not be_able_to(:edit, campus_only_collection)
      should_not be_able_to(:edit, private_collection)
      should_not be_able_to(:destroy, public_collection)
      should_not be_able_to(:destroy, campus_only_collection)
      should_not be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
    }
  end

  describe 'as a login user with no roles' do
    let(:current_user) { FactoryGirl.create(:user) }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, public_collection)

      should_not be_able_to(:read, campus_only_object_resource)
      should_not be_able_to(:read, private_object_resource)
      should_not be_able_to(:edit, public_object_resource)
      should_not be_able_to(:update, public_object_resource)
      should_not be_able_to(:create, ObjectResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, public_object_resource)
      should_not be_able_to(:destroy, admin_file)
      should_not be_able_to(:file_manager, public_object_resource)
      should_not be_able_to(:save_structure, public_object_resource)
      should_not be_able_to(:download, admin_file)

      should_not be_able_to(:read, campus_only_collection)
      should_not be_able_to(:read, private_collection)
      should_not be_able_to(:edit, public_collection)
      should_not be_able_to(:edit, campus_only_collection)
      should_not be_able_to(:edit, private_collection)
      should_not be_able_to(:destroy, public_collection)
      should_not be_able_to(:destroy, campus_only_collection)
      should_not be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
    }
  end

  describe 'as an anonymous user' do
    let(:current_user) { nil }

    it {
      should be_able_to(:read, public_object_resource)
      should be_able_to(:read, public_collection)

      should_not be_able_to(:read, campus_only_object_resource)
      should_not be_able_to(:read, private_object_resource)
      should_not be_able_to(:edit, public_object_resource)
      should_not be_able_to(:update, public_object_resource)
      should_not be_able_to(:create, ObjectResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, public_object_resource)
      should_not be_able_to(:destroy, admin_file)
      should_not be_able_to(:file_manager, public_object_resource)
      should_not be_able_to(:save_structure, public_object_resource)
      should_not be_able_to(:download, admin_file)

      should_not be_able_to(:read, campus_only_collection)
      should_not be_able_to(:read, private_collection)
      should_not be_able_to(:edit, public_collection)
      should_not be_able_to(:edit, campus_only_collection)
      should_not be_able_to(:edit, private_collection)
      should_not be_able_to(:destroy, public_collection)
      should_not be_able_to(:destroy, campus_only_collection)
      should_not be_able_to(:destroy, private_collection)

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
    }
  end
end
