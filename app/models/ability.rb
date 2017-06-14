class Ability
  include Hydra::Ability

  include Hyrax::Ability

  # override user_groups method to use default institutional visibility for campus group access
  def user_groups
    user_grps = super
    if current_user.anonymous?
      user_grps.delete(Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED.to_s)
    end
    user_grps
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    return unless admin?
    can [:manage], :all
  end

  def editor_permissions
    alias_action :edit, to: :update
    alias_action :show, to: :read
    alias_action :discover, to: :read

    # user can version if they can edit
    alias_action :versions, to: :update
    alias_action :file_manager, to: :update

    can :read, :all
    can :manage, [AdminSet, Hyrax::PermissionTemplate, Hyrax::PermissionTemplateAccess]
    can [:create, :edit, :update, :destroy], Hyrax::PermissionTemplate
    can [:create, :edit, :update, :destroy], Hyrax::PermissionTemplateAccess

    can [:create, :update, :destroy], SolrDocument
    can [:create, :edit, :update, :destroy], ActiveFedora::Base
    can [:create, :edit, :update, :download, :destroy], FileSet
    can [:create, :edit], BatchImportItem
  end

  def curator_permissions
    can [:read], :all
    can [:download], FileSet
  end

  def campus_permissions; end

  def anonymous_permissions; end

  # Define any customized permissions here.
  def custom_permissions
    alias_action :show, to: :read

    Rails.configuration.dams_user_roles.each do |role|
      send "#{role}_permissions" if current_user.send "#{role}?"
    end
  end

  private

    def curation_concerns
      Hyrax.config.curation_concerns
    end
end
