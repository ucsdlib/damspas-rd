module Sufia
  class WorkIndexer < CurationConcerns::WorkIndexer
    include IndexesAttributes

    self.thumbnail_path_service = ObjectThumbnailPathService
    def generate_solr_document
      super.tap do |solr_doc|
        # This enables us to return a Work when we have a FileSet that matches
        # the search query.  While at the same time allowing us not to return Collections
        # when a work in the collection matches the query.
        solr_doc[Solrizer.solr_name('file_set_ids', :symbol)] = solr_doc[Solrizer.solr_name('member_ids', :symbol)]

        admin_set_label = object.admin_set.to_s
        solr_doc[Solrizer.solr_name('admin_set', :facetable)] = admin_set_label
        solr_doc[Solrizer.solr_name('admin_set', :stored_searchable)] = admin_set_label
      end
    end
  end
end
