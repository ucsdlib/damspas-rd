class UcsdAgentForm
  include HydraEditor::Form

  self.model_class = UcsdAgent

  self.required_fields = [:label, :agent_type]

  self.terms = [:agent_type, :label, :alternate_label, :orcid,
                :exact_match, :close_match, :related_match, :different_from]

  def title
    model.label
  end
end
