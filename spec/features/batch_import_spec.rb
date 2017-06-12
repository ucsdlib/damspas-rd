require 'rails_helper'
include Warden::Test::Helpers

feature 'Batch Import' do
  context 'a logged in user in editor role' do
    let(:user) { create(:editor) }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true),
             agent_type: 'user',
             agent_id: user.user_key)
      sign_in user
    end

    scenario 'should be able to access the Batch Import tool' do
      visit '/dashboard'
      expect(page).to have_link 'Batch Import'
      click_link 'Batch Import'
      expect(page).to have_selector("h1", text: 'Batch Import')
      expect(page).to have_css("a[href='#metadata']")
      expect(page).to have_css("a[href='#files']")
    end
  end
end
