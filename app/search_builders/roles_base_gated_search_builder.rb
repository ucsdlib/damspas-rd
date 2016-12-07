module RolesBaseGatedSearchBuilder
  extend ActiveSupport::Concern

  def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    user_access_filters = []

    # Grant access based on user id & group, skip if admin, editor, or curator
    if !(ability.current_user.admin? || ability.current_user.editor? || ability.current_user.curator?)
      solr_access_filters_logic.each do |method_name|
        user_access_filters += send(method_name, permission_types, ability)
      end
    end
    user_access_filters
  end
end
