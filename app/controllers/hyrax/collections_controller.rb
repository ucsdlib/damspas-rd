module Hyrax
  class CollectionsController < ApplicationController
    include Hyrax::CollectionsControllerBehavior
    include Hyrax::BreadcrumbsForCollections

  include LocalAuthorityHashConverter

  def form
    attrs = @collection.attributes.dup
    attrs.each do |key, val|
      @collection.attributes[key] = hash_to_uri val
    end

    @form ||= form_class.new(@collection)
  end

  def form_class
    ::CollectionEditForm
  end

  def single_item_search_builder
    ::WorkSearchBuilder.new(self).with(params.except(:q, :page))
  end
  end
end
