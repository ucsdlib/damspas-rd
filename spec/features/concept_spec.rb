require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a Concept' do
  context 'a logged in user' do
    let(:user) { create(:admin) }

    before do
      sign_in user
    end

    let(:subject) { Concept.create(label: ['Test Linked Concept']) }
    scenario 'should be able to access the Concept form and create Concept' do
      visit root_path
      expect(page).to have_link 'New Subject'

      click_link 'New Subject'
      expect(page).to have_selector 'h1', text: 'Create a New Concept Record'

      fill_in 'concept_label', with: 'Test New Concept'
      click_button 'Save'
      expect(page).to have_content 'Test New Concept'
    end

    scenario 'should be able to create Concept that links a closeMatch URL' do
      visit "/records/new?type=Concept&locale=en"

      expect(page).to have_selector 'h1', text: 'Create a New Concept Record'

      fill_in 'concept_label', with: 'Test New Concept with Close Match'
      fill_in 'concept_close_match', with: subject.uri.to_s
      click_button 'Save'
      expect(page).to have_content 'Test New Concept with Close Match'
      expect(page).to have_link 'Test Linked Concept'
    end

    scenario 'should be able to edit Concept ' do
      visit "/records/new?type=Concept&locale=en"

      expect(page).to have_selector 'h1', text: 'Create a New Concept Record'

      fill_in 'concept_label', with: 'Test Edit Concept'
      click_button 'Save'
      expect(page).to have_content 'Test Edit Concept'
      find('.btn-edit').click
      fill_in 'concept_label', with: 'Test Edit Concept Updated'
      click_button 'Save'
      expect(page).to have_content 'Test Edit Concept Updated'
    end
  end
end