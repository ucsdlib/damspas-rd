require 'rails_helper'
include Warden::Test::Helpers

feature 'a user with role' do

  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:public_object_resource) { FactoryGirl.create(:object_resource, title: ["Public Object Title"], :user => admin_user) }
  let!(:campus_only_object_resource) { FactoryGirl.create(:campus_only_object_resource, title: ["Campus Only Object Title"], user: admin_user) }
  let!(:private_object_resource) { FactoryGirl.create(:private_object_resource, title: ["Private Object Title"], user: admin_user) }

  let!(:metadata_only_object_resource) { FactoryGirl.create(:metadata_only_object_resource_with_files, title: ["Metadata-only Object Title"], user: admin_user) }
  let!(:culturally_sensitive_object_resource) { FactoryGirl.create(:culturally_sensitive_object_resource_with_files, title: ["Culturally-sensitive Object Title"], user: admin_user) }
  let!(:suppress_discovery_object_resource) { FactoryGirl.create(:suppress_discovery_object_resource_with_files, title: ["Suppress-discovery Object Title"], user: admin_user) }

  let!(:public_collection) { FactoryGirl.create(:collection, title: ["Public Collection Title"], :user => admin_user) }
  let!(:campus_only_collection) { FactoryGirl.create(:campus_only_collection, title: ["Campus Only Collection Title"], user: admin_user) }
  let!(:private_collection) { FactoryGirl.create(:private_collection, title: ["Private Collection Title"], user: admin_user) }

  context 'admin' do
    let!(:user) { FactoryGirl.create(:admin) }
    before do
        sign_in user
    end

    scenario 'should be able to discover any collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).to have_link("Campus Only Object Title")
      expect(page).to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).to have_link("Campus Only Collection Title")
      expect(page).to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end

  context 'editor' do
    let!(:user) { FactoryGirl.create(:editor) }
    before do
        sign_in user
    end

    scenario 'should be able to discover any collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).to have_link("Campus Only Object Title")
      expect(page).to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).to have_link("Campus Only Collection Title")
      expect(page).to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end

  context 'curator' do
    let!(:user) { FactoryGirl.create(:curator) }
    before do
        sign_in user
    end

    scenario 'should be able to discover any collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).to have_link("Campus Only Object Title")
      expect(page).to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).to have_link("Campus Only Collection Title")
      expect(page).to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end

  context 'campus' do
    let!(:user) { FactoryGirl.create(:campus) }
    before do
        sign_in user
    end

    scenario 'should be able to discover public and campus only collections and objects but not private collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).to have_link("Campus Only Object Title")
      expect(page).not_to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).to have_link("Campus Only Collection Title")
      expect(page).not_to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end

  context 'logged in with no role' do
    let!(:user) { FactoryGirl.create(:user) }
    before do
        sign_in user
    end

    scenario 'should be able to discover public and campus only collections and objects but not private collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).not_to have_link("Campus Only Object Title")
      expect(page).not_to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).not_to have_link("Campus Only Collection Title")
      expect(page).not_to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end

  context 'anonymous' do
    scenario 'should be able to discover public collections and objects but not campus only and private collections and objects' do
      visit "/catalog?q="
      expect(page).to have_link("Public Object Title")
      expect(page).not_to have_link("Campus Only Object Title")
      expect(page).not_to have_link("Private Object Title")

      expect(page).to have_link("Public Collection Title")
      expect(page).not_to have_link("Campus Only Collection Title")
      expect(page).not_to have_link("Private Collection Title")

      expect(page).to have_link("Metadata-only Object Title")
      expect(page).to have_link("Culturally-sensitive Object Title")
    end

    scenario 'should not be able to find suppress discovery objects' do
      visit "/catalog?q="
      expect(page).not_to have_link("Suppress-discovery Object Title")
    end
  end
end

feature 'Visitor wants to browse and search' do

  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    scenario 'topic facet page has A-Z links' do
      visit facet_catalog_path("topic_sim", :'facet.sort' => 'index')
      expect(page).to have_link('A', href: '/catalog/facet/topic_sim?facet.prefix=A&facet.sort=index&locale=en' )
      expect(page).to have_link('Z', href: '/catalog/facet/topic_sim?facet.prefix=Z&facet.sort=index&locale=en' )
    end

    scenario 'creator facet page has A-Z links' do
      visit facet_catalog_path("creator_sim", :'facet.sort' => 'index')
      expect(page).to have_link('A', href: '/catalog/facet/creator_sim?facet.prefix=A&facet.sort=index&locale=en' )
      expect(page).to have_link('Z', href: '/catalog/facet/creator_sim?facet.prefix=Z&facet.sort=index&locale=en' )
    end
  end

feature 'Visitor goes to advanced search page' do
  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:object_resource) { FactoryGirl.create(:object_resource, title: ["Object Title"], topic: ["New Subject"], :user => admin_user) }

  scenario 'to search by title' do
    visit "/advanced"
    expect(page).to have_selector('h1', :text => 'More Search Options')
    
    fill_in 'Title', with: "Object Title"
    click_button 'Search'
    expect(page).to have_content 'Object Title'
  end

  scenario 'to search by subject' do
    visit "/advanced"
    expect(page).to have_selector('h3', :text => 'have these attributes')
    
    fill_in 'Subject', with: "New Subject"
    click_button 'Search'
    expect(page).to have_content 'New Subject'
  end
 end
end