require 'rails_helper'
include Warden::Test::Helpers

feature 'Pages' do
  let!(:admin_user) { FactoryGirl.create(:admin) }

  context 'a logged in user' do
    let(:user) { create(:admin) }

    before do
      sign_in user
    end

    scenario 'should be able to see Contact page' do
      visit root_path
      click_link 'Contact'
      expect(page).to have_content 'Issue Type'
      select 'General inquiry or request', from: "contact_form_category"
      fill_in 'contact_form_subject', with: 'Test Subject'
      fill_in 'contact_form_message', with: 'Test Message'
      click_button 'Send'
      expect(page).to have_content 'Thank you for your message!'
    end

    scenario 'should be able to see FAQ page' do
      visit root_path
      click_link 'FAQ'
      click_button 'Edit'
      fill_in 'text_area_faq_page', with: 'Frequently Asked Questions (FAQ)'
      click_button 'Save'
      expect(page).to have_content 'Frequently Asked Questions (FAQ)'
    end

    scenario 'should be able to see Help page' do
      visit root_path
      click_link 'Help'
      click_button 'Edit'
      fill_in 'text_area_help_page', with: 'Help Test'
      click_button 'Save'
      expect(page).to have_content 'Help'
    end

    scenario 'should be able to see About page' do
      visit root_path
      click_link 'About'
      click_button 'Edit'
      fill_in 'text_area_about_page', with: 'About Digital Collections'
      click_button 'Save'
      expect(page).to have_content 'About Digital Collections'
    end

    scenario 'should be able to see Search Tips page' do
      visit root_path
      click_link 'Search Tips'
      click_button 'Edit'
      fill_in 'text_area_search-tips_page', with: 'Search Tips'
      click_button 'Save'
      expect(page).to have_content 'Search Tips'
    end

    scenario 'should be able to see Take Down Policy page' do
      visit root_path
      click_link 'Take Down Policy'
      click_button 'Edit'
      fill_in 'text_area_takedown_page', with: 'Notice and Takedown Policy'
      click_button 'Save'
      expect(page).to have_content 'Notice and Takedown Policy'
    end
  end
end
