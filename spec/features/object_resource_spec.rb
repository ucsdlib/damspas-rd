# Generated via
#  `rails generate hyrax:work ObjectResource`
require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a ObjectResource' do

  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:public_object_resource) { FactoryGirl.create(:object_resource, title: ["Public Object Title"], :user => admin_user) }
  let!(:campus_only_object_resource) { FactoryGirl.create(:campus_only_object_resource, title: ["Campus Only Object Title"], user: admin_user) }
  let!(:private_object_resource) { FactoryGirl.create(:private_object_resource, title: ["Private Object Title"], user: admin_user) }

  context 'a logged in user in admin role' do
    let(:user) { create(:admin) }

    before do
      sign_in user
      language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
      language_authority_name = Qa::LocalAuthority.find_or_create_by(name: 'languages')
      @authority_lang = Qa::LocalAuthorityEntry.create(
          local_authority: language_authority_name,
          label: 'Language',
          uri: language_uri)
    end

    after do
      @authority_lang.delete
    end

    scenario 'should be able to create and edit private object'do
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
        fill_in "object_resource_#{prop.name.to_s}", with: "#{prop.name.to_s}#1"
      end
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource - Identifiers'
      IdentifierSchema.properties.each do |prop|
        expect(page).to have_content "#{prop.name.to_s}#1"
      end
    end
  end

  context 'object resource with related resource' do
    let(:user) { create(:admin) }
    before do
      sign_in user
      @obj_nested = ObjectResource.create(title: ["Test ObjectResource - Related resource"], related_resource_attributes: [{related_type: ['relation'], name: ['Name'], url: ['http://test.com/related']}])
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
      visit "#{hyrax_object_resource_path @obj_nested.id}"
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
      visit "#{hyrax_object_resource_path private_object_resource.id}"
      expect(page).to have_content 'Private Object Title'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'Title', with: 'Private Object Title - Editor Edited'
      click_button 'Save'
      expect(page).to have_content 'Private Object Title - Editor Edited'
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
      visit "#{hyrax_object_resource_path public_object_resource.id}"
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects but no editing allowed' do
      visit "#{hyrax_object_resource_path campus_only_object_resource.id}"
      expect(page).to have_content 'Campus Only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any private objects but no editing allowed' do
      visit "#{hyrax_object_resource_path private_object_resource.id}"
      expect(page).to have_content 'Private Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
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
      visit "#{hyrax_object_resource_path public_object_resource.id}"
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects but no editing allowed' do
      visit "#{hyrax_object_resource_path campus_only_object_resource.id}"
      expect(page).to have_content 'Campus Only Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should not be able to read any private objects' do
      visit "#{hyrax_object_resource_path private_object_resource.id}"
      expect(page).not_to have_content 'Private Object Title'
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'an anonymous user' do
    scenario 'should not allow to create new object' do
      visit new_hyrax_object_resource_path
      expect(page).to have_current_path new_user_session_path
    end

    scenario 'should be able to read any public objects but no editing allowed' do
      visit "#{hyrax_object_resource_path public_object_resource.id}"
      expect(page).to have_content 'Public Object Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only objects' do
      visit "#{hyrax_object_resource_path campus_only_object_resource.id}"
      expect(page).to have_current_path new_user_session_path
    end

    scenario 'should not be able to read any private objects' do
      visit "#{hyrax_object_resource_path private_object_resource.id}"
      expect(page).to have_current_path new_user_session_path
    end
  end
end
