require 'rails_helper'
include Warden::Test::Helpers

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