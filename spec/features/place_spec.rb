require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Place' do
  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    scenario 'should be able to access the Place form and create Place record' do
      visit root_path
      expect(page).to have_link 'New Place'

      click_link 'New Place'
      expect(page).to have_selector 'h1', text: 'Create a New Place Record'

      fill_in 'place_label', with: 'Test New Place'
      click_button 'Save'
      expect(page).to have_content 'Test New Place'
    end

    scenario 'should not be able to create Place record with duplicate label' do
      visit "/records/new?type=Place&commit=Next"

      expect(page).to have_selector 'h1', text: 'Create a New Place Record'

      fill_in 'place_label', with: 'Test dup Place Record'
      click_button 'Save'
      expect(page).to have_content 'Test dup Place Record'
      find('.btn-new').click
      fill_in 'place_label', with: 'Test dup Place Record'
      click_button 'Save'
      expect(page).to have_content ("'Test dup Place Record' already exists!")
    end

    scenario 'should be able to edit Place record' do
      visit "/records/new?type=Place&commit=Next"

      expect(page).to have_selector 'h1', text: 'Create a New Place Record'

      fill_in 'place_label', with: 'Test Edit Place Record'
      click_button 'Save'
      expect(page).to have_content 'Test Edit Place Record'
      find('.btn-edit').click
      fill_in 'place_label', with: 'Test Edit Place Record Updated'
      click_button 'Save'
      expect(page).to have_content 'Test Edit Place Record Updated'
    end
  end
end