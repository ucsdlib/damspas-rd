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

    scenario 'should be able to edit and see FAQ page' do
      visit '/dashboard'
      find(:xpath, "//a[@href='/pages/edit?locale=en']").click
      click_link 'FAQ Page'
      fill_in 'content_block_faq', with: 'Frequently Asked Questions (FAQ)'
      find(:xpath, "(//input[@type='submit'])[3]").click
      expect(page).to have_content 'Frequently Asked Questions (FAQ)'

      visit root_path
      click_link 'FAQ'
      expect(page).to have_content 'Frequently Asked Questions (FAQ)'
    end

    scenario 'should be able to edit and see Help page' do
      visit '/dashboard'
      find(:xpath, "//a[@href='/pages/edit?locale=en']").click
      click_link 'Help Page'
      fill_in 'content_block_help', with: 'Help Test'
      find(:xpath, "(//input[@type='submit'])[2]").click
      expect(page).to have_content 'Help Test'

      visit root_path
      click_link 'Help'
      expect(page).to have_content 'Help Test'
    end

    scenario 'should be able to edit and see About page' do
      visit '/dashboard'
      find(:xpath, "//a[@href='/pages/edit?locale=en']").click
      click_link 'About Page'
      fill_in 'content_block_about', with: 'About Digital Collections'
      find(:xpath, "(//input[@type='submit'])[1]").click
      expect(page).to have_content 'About Digital Collections'

      visit root_path
      click_link 'About'
      expect(page).to have_content 'About Digital Collections'
    end

    scenario 'should be able to edit and see Search Tips page' do
      visit '/dashboard'
      find(:xpath, "//a[@href='/pages/edit?locale=en']").click
      click_link 'Search Tips Page'
      fill_in 'content_block_search_tips', with: 'Search Tips'
      find(:xpath, "(//input[@type='submit'])[5]").click
      expect(page).to have_content 'Search Tips'

      visit root_path
      click_link 'Search Tips'
      expect(page).to have_content 'Search Tips'
    end

    scenario 'should be able to edit and see Take Down Policy page' do
      visit '/dashboard'
      find(:xpath, "//a[@href='/pages/edit?locale=en']").click
      click_link 'Take Down Page'
      fill_in 'content_block_takedown', with: 'Notice and Takedown Policy'
      find(:xpath, "(//input[@type='submit'])[4]").click
      expect(page).to have_content 'Notice and Takedown Policy'

      visit root_path
      click_link 'Take Down Policy'
      expect(page).to have_content 'Notice and Takedown Policy'
    end
  end
end
