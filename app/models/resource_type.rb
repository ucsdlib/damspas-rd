# ResourceType is a class of Authority
class ResourceType < Authority
   extend ActiveTriples::Configurable

  configure type: ::RDF::Vocab::SKOS.Concept

  validates :public_uri, url: true
end

