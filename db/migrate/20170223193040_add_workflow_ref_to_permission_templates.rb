class AddWorkflowRefToPermissionTemplates < ActiveRecord::Migration[5.0]
  def change
    add_reference :permission_templates, :workflow, foreign_key: true
  end
end
