# Generated via
#  `rails generate curation_concerns:work ObjectResource`
require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a ObjectResource' do
  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      sign_in user
      @res_type = ResourceType.create(label: ["Resource Type"], public_uri: ["http://id.loc.gov/vocabulary/resourceTypes/resourcetype"])
      @language = Language.create(label: ["Language"], public_uri: ["http://id.loc.gov/vocabulary/iso639-2/language"])
    end

    after do
      @res_type.delete
      @language.delete
    end

    scenario do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
    end

    scenario 'should create object' do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'Description', with: 'Test Description'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test Description'
    end

    scenario 'should contains UCSD custom term General Note' do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'General note', with: 'Test General Note'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test General Note'
    end

    scenario 'should has UCSD name space term Physical Description' do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource'
      fill_in 'Physical description', with: 'Test Physical Description'
      click_button 'Save'
      expect(page).to have_content 'Test ObjectResource'
      expect(page).to have_content 'Test Physical Description'
    end

    scenario 'should create object with language url' do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Language'
      select 'Language', from: "object_resource_language"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Language'
      expect(page).to have_selector 'li.language', text: 'Language'
    end

    scenario 'should create object with resource type label from type url' do
      visit new_curation_concerns_object_resource_path
      fill_in 'Title', with: 'Test ObjectResource - Resource Type'
      select 'Resource Type', from: "object_resource_resource_type"
      click_button 'Save'
      expect(page).to have_selector 'h1', text: 'Test ObjectResource - Resource Type'
      expect(page).to have_selector 'li.resource_type', text: 'Resource Type'
    end
  end
end
