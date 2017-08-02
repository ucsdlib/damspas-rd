require 'rails_helper'
include Warden::Test::Helpers

feature 'Complex Object' do
  context 'a logged in user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:parent) { FactoryGirl.create(:object_resource, user: user, title: ["Parent Object"]) }
    let(:child)  { FactoryGirl.create(:object_resource_with_one_file, user: user, title: ["Suppressed Component"]) }

    before do
      login_as user
      parent.ordered_members << child
      parent.save!
    end

    scenario 'should not display components of a complex object' do
      visit "/catalog?search_field=all_fields&q=Suppressed"
      expect(page).to have_link("Parent Object")
      expect(page).not_to have_link("Suppressed Component")
    end
  end
end
