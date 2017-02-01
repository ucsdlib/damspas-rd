require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Collection' do

  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:public_collection) { FactoryGirl.create(:collection, title: ["Public Collection Title"], :user => admin_user) }
  let!(:campus_only_collection) { FactoryGirl.create(:campus_only_collection, title: ["Campus Only Collection Title"], user: admin_user) }
  let!(:private_collection) { FactoryGirl.create(:private_collection, title: ["Private Collection Title"], user: admin_user) }

  context 'a logged in user with admin role' do
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

    scenario 'is allowed to create collections' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'collection_title', with: 'Test Collection Edited'
      click_button 'Update Collection'
      expect(page).to have_content 'Test Collection Edited'
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

    scenario 'should create collection with language label' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection - Language'
      fill_in 'collection_language', with: 'Language'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection - Language'
      expect(page).to have_selector 'a', text: 'Language'
    end

    scenario 'should get validation message with an invalid language label' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection - Language'
      fill_in 'collection_language', with: 'Invalid Language'
      click_button("Create Collection")
      expect(page).to have_content 'Invalid label for language field!'
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

  context 'a logged in user with editor role' do
    let(:user) { create(:editor) }
    before do
      sign_in user
    end

    scenario 'is allowed to create collections' do
      visit '/dashboard'
      first('#hydra-collection-add').click
      expect(page).to have_content 'Create New Collection'
      click_link('Additional fields')

      fill_in 'collection_title', with: 'Test Collection - Editor'
      click_button("Create Collection")
      expect(page).to have_selector 'h1', text: 'Test Collection - Editor'
      find(:xpath, "(//a[text()='Edit'])[1]").click
      fill_in 'collection_title', with: 'Test Collection - Editor Edited'
      click_button 'Update Collection'
      expect(page).to have_content 'Test Collection - Editor Edited'
    end

    scenario 'is allowed to read and edit any public collections' do
      visit "#{hyrax.collection_path public_collection.id}"
      expect(page).to have_content 'Public Collection Title'
      find(:xpath, "//a[text()='Edit']").click
      fill_in 'collection_title', with: 'Public Collection Title - Editor Edited'
      click_button 'Update Collection'
      expect(page).to have_content 'Public Collection Title - Editor Edited'
    end

    scenario 'is allowed to read and edit any any campus only collections' do
      visit "#{hyrax.collection_path campus_only_collection.id}"
      expect(page).to have_content 'Campus Only Collection Title'
      find(:xpath, "//a[text()='Edit']").click
      fill_in 'collection_title', with: 'Campus Only Collection Title - Editor Edited'
      click_button 'Update Collection'
      expect(page).to have_content 'Campus Only Collection Title - Editor Edited'
    end

    scenario 'is allowed to read and edit any private collections' do
      visit "#{hyrax.collection_path private_collection.id}"
      expect(page).to have_content 'Private Collection Title'
      find(:xpath, "//a[text()='Edit']").click
      fill_in 'collection_title', with: 'Private Collection Title - Editor Edited'
      click_button 'Update Collection'
      expect(page).to have_content 'Private Collection Title - Editor Edited'
    end
  end

  context 'a logged in user with curator role' do
    let(:user) { create(:curator) }
    before do
      sign_in user
    end

    scenario 'is allowed to create collections' do
      visit hyrax.new_collection_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario 'is allowed to read any public collections but no editing allowed' do
      visit "#{hyrax.collection_path public_collection.id}"
      expect(page).to have_content 'Public Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'is allowed to read and edit any any campus only collections but no editing allowed' do
      visit "#{hyrax.collection_path campus_only_collection.id}"
      expect(page).to have_content 'Campus Only Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'is allowed to read and edit any private collections but no editing allowed' do
      visit "#{hyrax.collection_path private_collection.id}"
      expect(page).to have_content 'Private Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end
  end

  context 'an campus user' do
    let(:user) { create(:campus) }
    before do
      sign_in user
    end

    scenario 'should not be able to create new collection'do
      visit hyrax.new_collection_path
      expect(page).to have_content 'You are not authorized to access this page.'
    end

    scenario 'should be able to read any public collections but no editing allowed' do
      visit "#{hyrax.collection_path public_collection.id}"
      expect(page).to have_content 'Public Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only collections but no editing allowed' do
      visit "#{hyrax.collection_path campus_only_collection.id}"
      expect(page).to have_content 'Campus Only Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should not be able to read any private collections' do
      visit "#{hyrax.collection_path private_collection.id}"
      expect(page).not_to have_content 'Private Collection Title'
      expect(page).to have_content 'You are not authorized to access this page'
    end
  end

  context 'an anonymous user' do
    scenario 'should not be able to create new collections'do
      visit hyrax.new_collection_path
      expect(page).to have_current_path new_user_session_path
    end

    scenario 'should be able to read any public collections but no editing allowed' do
      visit "#{hyrax.collection_path public_collection.id}"
      expect(page).to have_content 'Public Collection Title'
      expect(page).not_to have_xpath "//a[text()='Edit']"
    end

    scenario 'should be able to read any campus only collections' do
      visit "#{hyrax.collection_path campus_only_collection.id}"
      expect(page).to have_current_path new_user_session_path
    end

    scenario 'should not be able to read any private collections' do
      visit "#{hyrax.collection_path private_collection.id}"
      expect(page).to have_current_path new_user_session_path
    end
  end
end