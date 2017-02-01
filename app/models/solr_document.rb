# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

 def topic
   self[Solrizer.solr_name('topic')]
  end

  def brief_description
   self[Solrizer.solr_name('brief_description')]
  end

  def creator
    return [] if self[Solrizer.solr_name('creator')].nil?
    self[Solrizer.solr_name('creator')]
  end

  def contributor
    self[Solrizer.solr_name('contributor')]
  end

  def publisher
    self[Solrizer.solr_name('publisher')]
  end

  def created_date
    self[Solrizer.solr_name('created_date')]
  end

  def event_date
    self[Solrizer.solr_name('event_date')]
  end

  def spatial
    self[Solrizer.solr_name('spatial')]
  end

  def location
    self[Solrizer.solr_name('location')]
  end

  def general_note
    self[Solrizer.solr_name('general_note')]
  end

  def physical_description
    self[Solrizer.solr_name('physical_description')]
  end

  def location_of_originals
    self[Solrizer.solr_name('location_of_originals')]
  end

  def table_of_contents
    self[Solrizer.solr_name('table_of_contents')]
  end

  def finds
    self[Solrizer.solr_name('finds')]
  end

  def format
    self[Solrizer.solr_name('format')]
  end

  def local_attribution
    self[Solrizer.solr_name('local_attribution')]
  end

  def extent
    self[Solrizer.solr_name('extent')]
  end

  def exhibit
    self[Solrizer.solr_name('exhibit')]
  end

  def finding_aid
    self[Solrizer.solr_name('finding_aid')]
  end

  def resource_type
    self[Solrizer.solr_name('resource_type')]
  end

  # override itemtype for schema.org
  def itemtype
    Hyrax::ResourceTypesService.microdata_type(resource_type.first) if !resource_type.nil? && !resource_type.empty?
  end

  def language
    self[Solrizer.solr_name('language')]
  end
end
