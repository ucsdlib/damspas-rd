require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:public_object_resource) do
    FactoryGirl.build(:object_resource, user: admin_user)
  end

  let(:private_object_resource) do
    FactoryGirl.build(:private_object_resource, user: admin_user)
  end

  let(:campus_only_object_resource) do
    FactoryGirl.build(:campus_only_object_resource, user: admin_user)
  end

  let(:admin_file) { FactoryGirl.build(:file_set, user: admin_user) }

  let(:public_collection) do
    FactoryGirl.build(:collection, user: admin_user)
  end

  let(:campus_only_collection) do
    FactoryGirl.build(:campus_only_collection, user: admin_user)
  end

  let(:private_collection) do
    FactoryGirl.build(:private_collection, user: admin_user)
  end

  let(:jpeg_file_with_work) do
    FactoryGirl.create(:file_with_work, user: admin_user, content: File.open(fixture_path + '/files/image.jpg'))
  end

  let(:tiff_file_with_work) do
    FactoryGirl.create(:file_with_work, user: admin_user, content: File.open(fixture_path + '/files/file_3.tif'))
  end

  let(:preservation_master_file_with_work) do
    FactoryGirl.create(:file_with_work, user: admin_user)
  end

  let(:preservation_master_file) do
    File.open(fixture_path + '/files/file_3.tif')
  end

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
    [public_object_resource, private_object_resource, campus_only_object_resource, admin_file, public_collection,
     campus_only_collection, private_collection].each do |obj|
      allow(subject.cache).to receive(:get).with(obj.id)
                                           .and_return(Hydra::PermissionsSolrDocument.new(obj.to_solr, nil))
    end

    Hydra::Works::AddFileToFileSet.call(preservation_master_file_with_work,
                                        preservation_master_file, :preservation_master_file)
    preservation_master_file_with_work.save!
  end

  describe 'as an admin' do
    let(:current_user) { admin_user }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, campus_only_object_resource)
      is_expected.to be_able_to(:read, private_object_resource)
      is_expected.to be_able_to(:create, ObjectResource.new)
      is_expected.to be_able_to(:create, FileSet.new)
      is_expected.to be_able_to(:edit, public_object_resource)
      is_expected.to be_able_to(:edit, campus_only_object_resource)
      is_expected.to be_able_to(:edit, private_object_resource)
      is_expected.to be_able_to(:update, public_object_resource)
      is_expected.to be_able_to(:update, campus_only_object_resource)
      is_expected.to be_able_to(:update, private_object_resource)
      is_expected.to be_able_to(:destroy, public_object_resource)
      is_expected.to be_able_to(:destroy, campus_only_object_resource)
      is_expected.to be_able_to(:destroy, private_object_resource)
      is_expected.to be_able_to(:destroy, admin_file)

      is_expected.to be_able_to(:download, admin_file)
      is_expected.to be_able_to(:file_manager, public_object_resource)

      is_expected.to be_able_to(:create, Collection.new)
      is_expected.to be_able_to(:read, public_collection)
      is_expected.to be_able_to(:read, campus_only_collection)
      is_expected.to be_able_to(:read, private_collection)
      is_expected.to be_able_to(:edit, public_collection)
      is_expected.to be_able_to(:edit, campus_only_collection)
      is_expected.to be_able_to(:edit, private_collection)
      is_expected.to be_able_to(:destroy, public_collection)
      is_expected.to be_able_to(:destroy, campus_only_collection)
      is_expected.to be_able_to(:destroy, private_collection)

      is_expected.to be_able_to(:create, Role.new)
      is_expected.to be_able_to(:destroy, Role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end

  describe 'as an editor' do
    let(:current_user) { editor }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, campus_only_object_resource)
      is_expected.to be_able_to(:read, private_object_resource)
      is_expected.to be_able_to(:create, ObjectResource.new)
      is_expected.to be_able_to(:create, FileSet.new)
      is_expected.to be_able_to(:edit, public_object_resource)
      is_expected.to be_able_to(:edit, campus_only_object_resource)
      is_expected.to be_able_to(:edit, private_object_resource)
      is_expected.to be_able_to(:update, public_object_resource)
      is_expected.to be_able_to(:update, campus_only_object_resource)
      is_expected.to be_able_to(:update, private_object_resource)
      is_expected.to be_able_to(:destroy, public_object_resource)
      is_expected.to be_able_to(:destroy, campus_only_object_resource)
      is_expected.to be_able_to(:destroy, private_object_resource)
      is_expected.to be_able_to(:destroy, admin_file)

      is_expected.to be_able_to(:download, admin_file)
      is_expected.to be_able_to(:file_manager, public_object_resource)

      is_expected.to be_able_to(:create, Collection.new)
      is_expected.to be_able_to(:read, public_collection)
      is_expected.to be_able_to(:read, private_collection)
      is_expected.to be_able_to(:edit, public_collection)
      is_expected.to be_able_to(:edit, private_collection)
      is_expected.to be_able_to(:destroy, public_collection)
      is_expected.to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end

  describe 'as a curator' do
    let(:current_user) { curator }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, campus_only_object_resource)
      is_expected.to be_able_to(:read, private_object_resource)
      is_expected.to be_able_to(:download, admin_file)
      is_expected.to be_able_to(:read, public_collection)
      is_expected.to be_able_to(:read, campus_only_collection)
      is_expected.to be_able_to(:read, private_collection)

      is_expected.not_to be_able_to(:create, ObjectResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:file_manager, public_object_resource)
      is_expected.not_to be_able_to(:edit, public_object_resource)
      is_expected.not_to be_able_to(:update, public_object_resource)
      is_expected.not_to be_able_to(:destroy, public_object_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)

      is_expected.not_to be_able_to(:create, Collection.new)
      is_expected.not_to be_able_to(:edit, public_collection)
      is_expected.not_to be_able_to(:edit, campus_only_collection)
      is_expected.not_to be_able_to(:edit, private_collection)
      is_expected.not_to be_able_to(:destroy, public_collection)
      is_expected.not_to be_able_to(:destroy, campus_only_collection)
      is_expected.not_to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end

  describe 'as a campus user' do
    let(:current_user) { campus_user }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, campus_only_object_resource)
      is_expected.to be_able_to(:read, public_collection)
      is_expected.to be_able_to(:read, public_collection)
      is_expected.to be_able_to(:read, campus_only_collection)

      is_expected.not_to be_able_to(:read, private_object_resource)
      is_expected.not_to be_able_to(:edit, public_object_resource)
      is_expected.not_to be_able_to(:update, public_object_resource)
      is_expected.not_to be_able_to(:create, ObjectResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:destroy, public_object_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)
      is_expected.not_to be_able_to(:file_manager, public_object_resource)
      is_expected.not_to be_able_to(:save_structure, public_object_resource)
      is_expected.not_to be_able_to(:download, admin_file)
      is_expected.not_to be_able_to(:read, private_collection)
      is_expected.not_to be_able_to(:edit, public_collection)
      is_expected.not_to be_able_to(:edit, private_collection)
      is_expected.not_to be_able_to(:destroy, public_collection)
      is_expected.not_to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Collection.new)
      is_expected.not_to be_able_to(:read, private_collection)
      is_expected.not_to be_able_to(:edit, public_collection)
      is_expected.not_to be_able_to(:edit, campus_only_collection)
      is_expected.not_to be_able_to(:edit, private_collection)
      is_expected.not_to be_able_to(:destroy, public_collection)
      is_expected.not_to be_able_to(:destroy, campus_only_collection)
      is_expected.not_to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end

  describe 'as a login user with no roles' do
    let(:current_user) { FactoryGirl.create(:user) }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, public_collection)

      is_expected.not_to be_able_to(:read, campus_only_object_resource)
      is_expected.not_to be_able_to(:read, private_object_resource)
      is_expected.not_to be_able_to(:edit, public_object_resource)
      is_expected.not_to be_able_to(:update, public_object_resource)
      is_expected.not_to be_able_to(:create, ObjectResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:destroy, public_object_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)
      is_expected.not_to be_able_to(:file_manager, public_object_resource)
      is_expected.not_to be_able_to(:save_structure, public_object_resource)
      is_expected.not_to be_able_to(:download, admin_file)

      is_expected.not_to be_able_to(:read, campus_only_collection)
      is_expected.not_to be_able_to(:read, private_collection)
      is_expected.not_to be_able_to(:edit, public_collection)
      is_expected.not_to be_able_to(:edit, campus_only_collection)
      is_expected.not_to be_able_to(:edit, private_collection)
      is_expected.not_to be_able_to(:destroy, public_collection)
      is_expected.not_to be_able_to(:destroy, campus_only_collection)
      is_expected.not_to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end

  describe 'as an anonymous user' do
    let(:current_user) { nil }

    it do
      is_expected.to be_able_to(:read, public_object_resource)
      is_expected.to be_able_to(:read, public_collection)

      is_expected.not_to be_able_to(:read, campus_only_object_resource)
      is_expected.not_to be_able_to(:read, private_object_resource)
      is_expected.not_to be_able_to(:edit, public_object_resource)
      is_expected.not_to be_able_to(:update, public_object_resource)
      is_expected.not_to be_able_to(:create, ObjectResource.new)
      is_expected.not_to be_able_to(:create, FileSet.new)
      is_expected.not_to be_able_to(:destroy, public_object_resource)
      is_expected.not_to be_able_to(:destroy, admin_file)
      is_expected.not_to be_able_to(:file_manager, public_object_resource)
      is_expected.not_to be_able_to(:save_structure, public_object_resource)
      is_expected.not_to be_able_to(:download, admin_file)

      is_expected.not_to be_able_to(:read, campus_only_collection)
      is_expected.not_to be_able_to(:read, private_collection)
      is_expected.not_to be_able_to(:edit, public_collection)
      is_expected.not_to be_able_to(:edit, campus_only_collection)
      is_expected.not_to be_able_to(:edit, private_collection)
      is_expected.not_to be_able_to(:destroy, public_collection)
      is_expected.not_to be_able_to(:destroy, campus_only_collection)
      is_expected.not_to be_able_to(:destroy, private_collection)

      is_expected.not_to be_able_to(:create, Role.new)
      is_expected.not_to be_able_to(:destroy, role)

      is_expected.to be_able_to(:read, jpeg_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, tiff_file_with_work.original_file)
      is_expected.not_to be_able_to(:read, preservation_master_file_with_work.preservation_master_file)
    end
  end
end
