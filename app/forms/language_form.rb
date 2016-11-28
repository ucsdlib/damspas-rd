class LanguageForm
  include HydraEditor::Form

  self.model_class = Language

  self.required_fields = [:label, :public_uri]

  self.terms = [:label, :public_uri]

  def title
    model.label
  end
end
