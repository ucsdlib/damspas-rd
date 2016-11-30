require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Collection' do
  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      sign_in user
      language_uri = 'http://id.loc.gov/vocabulary/iso639-2/any'
      if Qa::Authorities::Local.subauthority_for('languages').find(language_uri).nil?
        lang = Qa::LocalAuthority.find_or_create_by(name: 'languages')
        Qa::LocalAuthorityEntry.create(
          local_authority: lang,
          label: 'Language',
          uri: language_uri)
      end
    end

    scenario 'in is allowed to create collections' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection'
    end

    scenario 'should see collection specific Brief Description text' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection'
    end

    scenario 'should see collection customized General Note' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection'
      fill_in 'collection_general_note', with: 'General Note'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection'
      expect(page).to have_content 'General Note'
    end

    scenario 'should create collection with language url' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection - Language'
      select 'Language', from: "collection_language"
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection - Language'
      expect(page).to have_selector 'a', text: 'Language'
    end

    scenario 'should create collection with resource type label from type url' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection - Resource Type'
      select 'Data', from: "collection_resource_type"
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection - Resource Type'
      expect(page).to have_selector 'a', text: 'Data'
    end
  end
end