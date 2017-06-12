# Generated via
#  `rails generate hyrax:work ObjectResource`
require 'rails_helper'
include Warden::Test::Helpers

feature 'ObjectResource' do
  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:public_object_resource) do
    FactoryGirl.create(:object_resource, title: ["Public Object Title"], user: admin_user)
  end
  let!(:campus_only_object_resource) do
    FactoryGirl.create(:campus_only_object_resource, title: ["Campus Only Object Title"], user: admin_user)
  end
  let!(:private_object_resource) do
    FactoryGirl.create(:private_object_resource, title: ["Private Object Title"], user: admin_user)
  end
  let!(:test_collection) { FactoryGirl.create(:collection, title: ["Collection Title"], user: admin_user) }
  let!(:test_object) do
    FactoryGirl.create(:object_resource, title: ["Object Title"],
                                         member_of_collections: [test_collection], user: admin_user)
  end

  let!(:embargoed_object_resource) do
    FactoryGirl.create(:with_embargo_date, title: ["Embargoed Object Title"], user: admin_user)
  end
  let!(:suppress_discovery_object_resource) do
    FactoryGirl.create(:suppress_discovery_object_resource_with_files,
                       title: ["Suppress-discovery Object Title"], user: admin_user)
  end
  let!(:metadata_only_object_resource) do
    FactoryGirl.create(:metadata_only_object_resource_with_files,
                       title: ["Metadata-only Object Title"], user: admin_user)
  end
  let!(:culturally_sensitive_object_resource) do
    FactoryGirl.create(:culturally_sensitive_object_resource_with_files,
                       title: ["Culturally-sensitive Object Title"], user: admin_user)
  end

  context 'a logged in user in admin role' do
    let(:user) { create(:admin) }

    before do
      sign_in user
      language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
      language_authority_name = Qa::LocalAuthority.find_or_create_by(name: 'languages')
      @authority_lang = Qa::LocalAuthorityEntry.create(
        local_authority: language_authority_name,
        label: 'Language',
        uri: language_uri
      )

      country_code_authority_name = Qa::LocalAuthority.find_or_create_by(name: 'country_codes')
      @authority_country_code = Qa::LocalAuthorityEntry.create(
        local_authority: country_code_authority_name,
        label: 'Country Name',
        uri: 'CODE'
      )

      @agent = UcsdAgent.create(label: 'Test Agent Name', agent_type: 'Person')
    end

    after do
      @authority_lang.delete
      @authority_country_code.delete
      @agent.delete
    end

    scenario 'should be able to create and edit private object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Test ObjectResource Edited'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource Edited'
    end

    scenario 'should create object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'Description', with: 'Test Description'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test Description'
    end

    scenario 'should contains UCSD custom term Note' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'Note', with: 'Test General Note'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test General Note'
    end

    scenario 'should has UCSD name space term Physical Description' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'Physical description', with: 'Test Physical Description'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test Physical Description'
    end

    scenario 'should create object with language label' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Language'
      fill_in 'object_resource_language', with: 'Language'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Language'
      expect(page).to have_selector 'li.language', text: 'Language'
    end

    scenario 'should create object with resource type label from type url' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Resource Type'
      select 'Data', from: "object_resource_resource_type"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Resource Type'
      expect(page).to have_selector 'li.resource_type', text: 'Data'
    end

    scenario 'should create object with identifiers' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Identifiers'
      IdentifierSchema.properties.each do |prop|
        fill_in "object_resource_#{prop.name}", with: "#{prop.name}#1"
      end
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource - Identifiers'
      IdentifierSchema.properties.each do |prop|
        expect(page).to have_content "#{prop.name}#1"
      end
    end

    scenario 'should create object with copyright status' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Copyright status'
      select 'copyrighted', from: "object_resource_copyright_status"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Copyright status'
      expect(page).to have_selector 'li.copyright_status',
                                    text: 'http://id.loc.gov/vocabulary/preservation/copyrightStatus/cpr'
    end

    scenario 'should create object with copyright jurisdiction' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Copyright jurisdiction'
      select 'Country Name', from: "object_resource_copyright_jurisdiction"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Copyright jurisdiction'
      expect(page).to have_selector 'li.copyright_jurisdiction', text: 'CODE'
    end

    scenario 'should create object with rights holder' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Rights holder'
      select 'Test Agent Name', from: "object_resource_rights_holder"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Rights holder'
      expect(page).to have_selector 'li.rights_holder', text: 'Test Agent Name'
    end

    scenario 'should create embargo object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Embargoed'
      choose 'object_resource_visibility_embargo'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Embargoed'
      expect(page).to have_selector 'span.label-warning', text: 'Embargo'
    end

    scenario 'should create metadata-only object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Metadata-only'
      choose 'object_resource_visibility_metadata_only'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Metadata-only'
      expect(page).to have_selector 'span.label-danger', text: 'Metadata Only'
    end

    scenario 'should create culturally-sensitive object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Culturally-sensitive'
      choose 'object_resource_visibility_culturally_sensitive'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Culturally-sensitive'
      expect(page).to have_selector 'span.label-warning', text: 'Culturally Sensitive'
    end

    scenario 'should create suppress-discovery object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Suppress-discovery'
      choose 'object_resource_visibility_suppress_discovery'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Suppress-discovery'
      expect(page).to have_selector 'span.label-info', text: 'Suppress Discovery'
    end

    scenario 'should see the Collection in breadcrumb after logged in' do
      visit hyrax_object_resource_path test_object.id
      within(:xpath, '//ul[@class="breadcrumb"]/li[2]') do
        expect(page).to have_content("Collection Title")
      end
    end
  end

  context 'object resource with related resource' do
    let(:user) { create(:admin) }

    before do
      sign_in user
      @obj_nested = ObjectResource.create(title: ["Test ObjectResource - Related resource"],
                                          related_resource_attributes: [{ related_type: ['relation'],
                                                                          name: ['Name'],
                                                                          url: ['http://test.com/related'] }])
    end

    after do
      @obj_nested.delete
    end

    scenario 'can create' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Related resource'
      select 'relation', from: "related_resource_0_related_type"
      fill_in "object_resource_related_resource_0_name", with: "related_resource_name"
      fill_in "object_resource_related_resource_0_url", with: "http://test.com/related_resource_url-1"
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource - Related resource'
      expect(page).to have_content 'related_resource_name'
    end

    scenario 'can update' do
      visit hyrax_object_resource_path @obj_nested.id
      expect(page).to have_content 'Test ObjectResource - Related resource'
      find(:xpath, "//a[text()='Edit']").click
      fill_in 'object_resource_title', with: 'Test ObjectResource - Related resource updated'
      fill_in "object_resource_related_resource_0_name", with: 'related_resource_name updated'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource - Related resource updated'
      expect(page).to have_content 'related_resource_name updated'
    end
  end

  context 'a logged in user in editor role' do
    let(:user) { create(:editor) }

    before do
      sign_in user
    end

    scenario 'should be able to create and edit private object' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource Editor'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource Editor'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Test ObjectResource Editor Edited'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource Editor Edited'
    end

    scenario 'should be able to read and edit any private object' do
      visit hyrax_object_resource_path private_object_resource.id
      expect(page).to have_content 'Private Object Title'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Private Object Title - Editor Edited'
      click_button 'Save'
      expect(page).to have_content 'Private Object Title - Editor Edited'
    end

    scenario 'should be able to read and edit any embargoed objects' do
      visit hyrax_object_resource_path embargoed_object_resource.id
      expect(page).to have_content 'Embargoed Object Title'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Embargoed Object Title - Editor Edited'
      click_button 'Save'
      expect(page).to have_content 'Embargoed Object Title - Editor Edited'
    end

    scenario 'should be able to create metadata-only object and change its visibility' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Metadata-only'
      choose 'object_resource_visibility_metadata_only'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Metadata-only'
      expect(page).to have_selector 'span.label-danger', text: 'Metadata Only'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Metadata-only Object Title - Changed to Culturally-sensitive'
      choose 'object_resource_visibility_culturally_sensitive'
      click_button 'Save'
      expect(page).to have_content 'Metadata-only Object Title - Changed to Culturally-sensitive'
      expect(page).to have_selector 'span.label-warning', text: 'Culturally Sensitive'
    end

    scenario 'should be able to create suppress discovery object and change its visibility' do
      visit new_hyrax_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Suppress-discovery'
      choose 'object_resource_visibility_suppress_discovery'
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Suppress-discovery'
      expect(page).to have_selector 'span.label-info', text: 'Suppress Discovery'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Suppress-discovery Test ObjectResource - Changed to Private'
      choose 'object_resource_visibility_restricted'
      click_button 'Save'
      expect(page).to have_content 'Suppress-discovery Test ObjectResource - Changed to Private'
      expect(page).to have_selector 'span.label-danger', text: 'Private'
    end
  end

  context 'a logged in user in curator role' do
    let(:user) { create(:curator) }

    before do
      sign_in user
    end

    scenario 'should not be able to create new object' do
      visit new_hyrax_object_resource_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario 'should be able to read any public objects but no editing allowed' do
      visit hyrax_object_resource_path public_object_resource.id
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects but no editing allowed' do
      visit hyrax_object_resource_path campus_only_object_resource.id
      expect(page).to have_content 'Campus Only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any private objects but no editing allowed' do
      visit hyrax_object_resource_path private_object_resource.id
      expect(page).to have_content 'Private Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any embargoed objects but no editing allowed' do
      visit hyrax_object_resource_path embargoed_object_resource.id
      expect(page).to have_content 'Embargoed Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read metadata-only objects and files but no editing allowed' do
      visit hyrax_object_resource_path metadata_only_object_resource.id
      expect(page).to have_content 'Metadata-only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path metadata_only_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
      expect(page).to have_selector 'span.label-danger', text: 'Metadata Only'
    end

    scenario 'should be able to read culturally-sensitive objects but no editing allowed' do
      visit hyrax_object_resource_path culturally_sensitive_object_resource.id
      expect(page).to have_content 'Culturally-sensitive Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path culturally_sensitive_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
      expect(page).to have_selector 'span.label-warning', text: 'Culturally Sensitive'
    end

    scenario 'should be able to read suppress-discovery Objects but no editing allowed' do
      visit hyrax_object_resource_path suppress_discovery_object_resource.id
      expect(page).to have_content 'Suppress-discovery Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path suppress_discovery_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
      expect(page).to have_selector 'span.label-info', text: 'Suppress Discovery'
    end
  end

  context 'an campus user' do
    let(:user) { create(:campus) }

    before do
      sign_in user
    end

    scenario 'should not allow to create new object' do
      visit new_hyrax_object_resource_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario 'should be able to read any public objects but no editing allowed' do
      visit hyrax_object_resource_path public_object_resource.id
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects but no editing allowed' do
      visit hyrax_object_resource_path campus_only_object_resource.id
      expect(page).to have_content 'Campus Only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should not be able to read any private objects' do
      visit hyrax_object_resource_path private_object_resource.id
      expect(page).not_to have_content 'Private Object Title'
      expect(page).to have_content 'Unauthorized'
    end

    scenario 'should not be able to read any embargoed objects' do
      visit hyrax_object_resource_path embargoed_object_resource.id
      expect(page).not_to have_content 'Embargoed Object Title'
      expect(page).to have_content 'Unauthorized'
    end

    scenario 'should be able to read metadata-only objects but no access to files' do
      visit hyrax_object_resource_path metadata_only_object_resource.id
      expect(page).to have_content 'Metadata-only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path metadata_only_object_resource.file_sets.first.id
      expect(page).to have_content 'not authorized'
    end

    scenario 'should be able to read culturally-sensitive objects and files' do
      visit hyrax_object_resource_path culturally_sensitive_object_resource.id
      expect(page).to have_content 'Culturally-sensitive Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path culturally_sensitive_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
    end

    scenario 'should be able to read suppress discovery object file' do
      visit hyrax_file_set_path suppress_discovery_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
    end
  end

  context 'an anonymous user' do
    scenario 'should not allow to create new object' do
      visit new_hyrax_object_resource_path
      expect(page).to have_current_path "#{new_user_session_path}?locale=en"
    end

    scenario 'should be able to read any public objects but no editing allowed' do
      visit hyrax_object_resource_path public_object_resource.id
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects' do
      visit hyrax_object_resource_path campus_only_object_resource.id
      expect(page).to have_current_path "#{new_user_session_path}?locale=en"
    end

    scenario 'should not be able to read any private objects' do
      visit hyrax_object_resource_path private_object_resource.id
      expect(page).to have_current_path "#{new_user_session_path}?locale=en"
    end

    scenario 'should not be able to read any embargoed objects' do
      visit hyrax_object_resource_path embargoed_object_resource.id
      expect(page).not_to have_content 'Embargoed Object Title'
      expect(page).to have_current_path "#{new_user_session_path}?locale=en"
    end

    scenario 'should be able to read metadata-only objects but no access to files' do
      visit hyrax_object_resource_path metadata_only_object_resource.id
      expect(page).to have_content 'Metadata-only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path metadata_only_object_resource.file_sets.first.id
      expect(page).to have_current_path "#{new_user_session_path}?locale=en"
    end

    scenario 'should be able to read culturally-sensitive objects and files' do
      visit hyrax_object_resource_path culturally_sensitive_object_resource.id
      expect(page).to have_content 'Culturally-sensitive Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
      visit hyrax_file_set_path culturally_sensitive_object_resource.file_sets.first.id
      expect(page).to have_content "File Details"
    end

    scenario 'should be able to read suppress-discovery object file' do
      visit hyrax_file_set_path suppress_discovery_object_resource.file_sets.first.id
      expect(page).to have_selector 'h2', text: "File Details"
    end

    scenario 'should see the Collection in breadcrumb in public view' do
      visit hyrax_object_resource_path test_object.id
      within(:xpath, '//ul[@class="breadcrumb"]/li[1]') do
        expect(page).to have_content("Collection Title")
      end
    end
  end
end
