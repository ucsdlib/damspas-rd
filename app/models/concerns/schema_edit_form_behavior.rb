module SchemaEditFormBehavior
  extend ActiveSupport::Concern

  included do
    (GeneralSchema.properties + IdentifierSchema.properties + LocalAuthoritySchema.properties + MarcrelSchema.properties).each do |prop|
      term = prop.name.to_sym
      delegate term, to: :model
      self.terms += [term] if !self.terms.include? term
    end
  end
end
