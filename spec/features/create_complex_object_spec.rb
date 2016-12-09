require 'rails_helper'
include Warden::Test::Helpers

feature 'Create a complex Object' do
  context 'a logged in user' do
    let(:user) { FactoryGirl.create(:user) }    
    let(:parent) { FactoryGirl.create(:object_resource, user: user, title: ["Parent Object"]) }
    let(:child1)  { FactoryGirl.create(:object_resource_with_one_file, user: user, title: ["Child 1"]) }
    let(:child2)  { FactoryGirl.create(:object_resource_with_file_and_object, user: user, title: ["Child 2"]) }
    let(:child3) { FactoryGirl.create(:object_resource, user: user, title: ["Child 3 Object - no attached file"]) }
    let(:grandChild1)  { FactoryGirl.create(:object_resource_with_files, user: user, title: ["Grand Child 1"]) }
    let(:grandChild2)  { FactoryGirl.create(:object_resource_with_one_file, user: user, title: ["Grand Child 2"]) }

    before do
      login_as user
      child1.ordered_members << grandChild1
      child1.ordered_members << grandChild2
      child1.save!      
      parent.ordered_members << child1
      parent.ordered_members << child2
      parent.ordered_members << child3
      parent.save!
    end

    scenario 'should display all components of a complex object' do
      visit curation_concerns_object_resource_path parent.id
      expect(parent.ordered_members.to_a.length).to eq 3
      expect(page).to have_content 'Parent Object'
      expect(page).to have_content 'Child 1'
      expect(page).to have_content 'Child 2'
      expect(page).to have_content 'Child 3 Object - no attached file'      
      expect(page).to have_content 'Grand Child 1'
      expect(page).to have_content 'Grand Child 2'
    end 
  end
end