class PlaceForm
  include HydraEditor::Form

  self.model_class = Place

  self.required_fields = [:label]

  self.terms = [:label, :alternate_label, :note, :point]

  def title
    model.label
  end
end
