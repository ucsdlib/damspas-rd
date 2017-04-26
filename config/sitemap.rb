# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://library.ucsd.edu/dc"
SitemapGenerator::Sitemap.compress = :all_but_first

SitemapGenerator::Sitemap.create do
  add '/catalog/facet/creator_sim?facet.sort=index'
  add '/catalog/facet/topic_sim?facet.sort=index'
  add '/catalog/facet/resource_type_sim?facet.sort=index'

  Page.find_each do |page|
     add view_page_path(page.slug), :lastmod => page.updated_at
     if SitemapGenerator::Sitemap.verbose
          Rails.logger.info "page title: #{page.slug}, lastmod: #{page.updated_at} "
     end
  end

#hyrax solr resources
  resources = {
    :ObjectResource => "concern/object_resources",
    :Collection => "collections"
  }
  resources.each do |record_type,record_path|
    begin
      rows = 100
      done = 0
      total = 0
      more_records = true
      solr_url = ActiveFedora.solr_config[:url]
      Rails.logger.info "solr: #{solr_url}"
      solr = RSolr.connect( :url => solr_url )
      while ( more_records )
        solr_response = solr.get 'select', :params => {:q => "has_model_ssim:#{record_type} AND read_access_group_ssim:public", :rows => rows, :wt => :ruby, :start => done, :sort => 'id asc'}
        response = solr_response['response']
        if done == 0
          if SitemapGenerator::Sitemap.verbose
            Rails.logger.info "#{record_type}: #{response['numFound']} records"
          end
          total = response["numFound"]
        end
        done += rows
         
        # output each record
        @records = response['docs']
        @records.each do |rec|
          id = rec['id']
          lastmod = rec['timestamp']
          if SitemapGenerator::Sitemap.verbose
            Rails.logger.info "#{record_type}: #{id}, lastmod: #{lastmod}"
          end
          add "#{record_path}/#{id}", priority: 0.9, :changefreq => 'monthly', :lastmod => lastmod
        end
    
        # stop looping if this is the last batch
        if done >= total
          more_records = false
        end
      end
    rescue Exception => e
      Rails.logger.info e.backtrace
    end
  end
end
