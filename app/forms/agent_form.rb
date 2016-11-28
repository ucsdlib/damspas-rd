class AgentForm
  include HydraEditor::Form

  self.model_class = Agent

  self.required_fields = [:label]

  self.terms = [:label, :alternate_label, :close_match, :related_match]

  def title
    model.label
  end
end
