# Agent is a class in EDM that has possible subclasses
# See:  http://www.europeana.eu/schemas/edm/Agent
class Agent < Authority
  configure type: ::RDF::Vocab::EDM.Agent
end
