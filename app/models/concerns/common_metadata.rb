require 'vocab/ucsd_terms'

module CommonMetadata
  extend ActiveSupport::Concern

  included do

    # GeneralSchema
    apply_schema GeneralSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    # IdentifierSchema
    apply_schema IdentifierSchema, ActiveFedora::SchemaIndexingStrategy.new(
      ActiveFedora::Indexers::GlobalIndexer.new([:stored_searchable, :symbol])
    )

    (LocalAuthoritySchema.properties + MarcrelSchema.properties).each do |prop|
      property prop.name, prop.to_h
    end

  end
end
