require 'rails_helper'
include Warden::Test::Helpers

feature 'a user with role' do

  let!(:admin_user) { FactoryGirl.create(:admin) }
  let!(:public_object_resource) { FactoryGirl.create(:object_resource, title: ["Public Object Title"], :user => admin_user) }
  let!(:campus_only_object_resource) { FactoryGirl.create(:campus_only_object_resource, title: ["Campus Only Object Title"], user: admin_user) }
  let!(:private_object_resource) { FactoryGirl.create(:private_object_resource, title: ["Private Object Title"], user: admin_user) }

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
    end
  end
end

feature 'Visitor wants to browse and search' do

  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    scenario 'topic facet page has a-z links' do
      visit facet_catalog_path("topic_sim", :'facet.sort' => 'index')
      expect(page).to have_link('a', href: '/catalog/facet/topic_sim?facet.prefix=a&facet.sort=index' )
      expect(page).to have_link('z', href: '/catalog/facet/topic_sim?facet.prefix=z&facet.sort=index' )
    end

    scenario 'creator facet page has a-z links' do
      visit facet_catalog_path("creator_sim", :'facet.sort' => 'index')
      expect(page).to have_link('a', href: '/catalog/facet/creator_sim?facet.prefix=a&facet.sort=index' )
      expect(page).to have_link('z', href: '/catalog/facet/creator_sim?facet.prefix=z&facet.sort=index' )
    end
  end
end