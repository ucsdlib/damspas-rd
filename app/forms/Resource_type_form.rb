class ResourceTypeForm
  include HydraEditor::Form

  self.model_class = ResourceType

  self.required_fields = [:label, :public_uri]

  self.terms = [:label, :public_uri]

  def title
    model.label
  end
end
