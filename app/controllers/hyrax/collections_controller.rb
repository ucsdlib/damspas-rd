module Hyrax
  class CollectionsController < ApplicationController
    include Hyrax::CollectionsControllerBehavior
    include Hyrax::BreadcrumbsForCollections

  include LocalAuthorityHashConverter

  def form
    attrs = @collection.attributes.dup
    attrs.each do |key, val|
      if key == 'language'
        language_service = LanguageSelectService.new
        val = val.collect { |v| language_service.get_label v }
        @collection.attributes[key].clear.push val
      else
        @collection.attributes[key] = hash_to_uri val
      end
    end

    @form ||= form_class.new(@collection)
  end

  def presenter_class
    ::CollectionShowPresenter
  end

  def form_class
    ::CollectionEditForm
  end

  def single_item_search_builder
    ::WorkSearchBuilder.new(self).with(params.except(:q, :page))
  end
  end
end
