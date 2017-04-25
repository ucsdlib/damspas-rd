require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a UcsdAgent' do
  context 'a logged in user' do
    let(:user) { create(:admin) }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true),
             agent_type: 'user',
             agent_id: user.user_key)
      sign_in user
    end

    let(:subject) { UcsdAgent.create(label: 'Test Linked Agent', agent_type: 'Person') }
    scenario 'should be able to access the agent form and create agent' do
      visit root_path
      expect(page).to have_link 'New Agent'

      click_link 'New Agent'
      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Create New UCSD Agent'
      fill_in 'ucsd_agent_orcid', with: 'http://test.com/orcid/any'
      click_button 'Save'
      expect(page).to have_content 'Test Create New UCSD Agent'
      expect(page).to have_content 'Person'
      expect(page).to have_content 'http://test.com/orcid/any'
    end

    scenario 'should be able to create agent that links a exactMatch URL' do
      visit "/records/new?type=UcsdAgent"

      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Create New UCSD Agent with Exact Match'
      fill_in 'ucsd_agent_exact_match', with: subject.uri.to_s
      click_button 'Save'
      expect(page).to have_content 'Test Create New UCSD Agent with Exact Match'
      expect(page).to have_link 'Test Linked Agent'
    end

    scenario 'should be able to create agent that links a closeMatch URL' do
      visit "/records/new?type=UcsdAgent"

      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Create New UCSD Agent with Close Match'
      fill_in 'ucsd_agent_close_match', with: subject.uri.to_s
      click_button 'Save'
      expect(page).to have_content 'Test Create New UCSD Agent with Close Match'
      expect(page).to have_link 'Test Linked Agent'
    end

    scenario 'should be able to create agent that links a relatedMatch URL' do
      visit "/records/new?type=UcsdAgent"

      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Create New UCSD Agent with Related Match'
      fill_in 'ucsd_agent_related_match', with: subject.uri.to_s
      click_button 'Save'
      expect(page).to have_content 'Test Create New UCSD Agent with Related Match'
      expect(page).to have_link 'Test Linked Agent'
    end

    scenario 'should be able to create agent that links a differentFrom URL' do
      visit "/records/new?type=UcsdAgent"

      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Create New UCSD Agent with Different From'
      fill_in 'ucsd_agent_different_from', with: subject.uri.to_s
      click_button 'Save'
      expect(page).to have_content 'Test Create New UCSD Agent with Different From'
      expect(page).to have_link 'Test Linked Agent'
    end

    scenario 'should be able to edit agent ' do
      visit "/records/new?type=UcsdAgent"

      expect(page).to have_selector 'h1', text: 'Create a New UCSD Agent Record'

      select 'Person', from: "ucsd_agent_agent_type"
      fill_in 'ucsd_agent_label', with: 'Test Edit UCSD Agent'
      click_button 'Save'
      expect(page).to have_content 'Test Edit UCSD Agent'
      find('.btn-edit').click
      fill_in 'ucsd_agent_label', with: 'Test Edit UCSD Agent Updated'
      click_button 'Save'
      expect(page).to have_content 'Test Edit UCSD Agent Updated'
    end
  end
end