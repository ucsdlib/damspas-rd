class DamsAuthoritiesController < ApplicationController
  include Blacklight::Base

  def show
    presenter
  end

  private

    def presenter
      @presenter ||= begin
        # Query Solr for the collection.
        # run the solr query to find the collection members
        q = { q: "id:#{params[:id]}" }
        response = repository.search(q)
        curation_concern = response.documents.first
        raise CanCan::AccessDenied unless curation_concern
        AuthorityShowPresenter.new(curation_concern, current_ability)
      end
    end
end
