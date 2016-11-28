class ConceptForm
  include HydraEditor::Form

  self.model_class = Concept

  self.required_fields = [:label]

  self.terms = [:label, :alternate_label, :close_match, :related_match, :note]

  def title
    model.label
  end
end
