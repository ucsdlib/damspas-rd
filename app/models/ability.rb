class Ability
  include Hydra::Ability

  include Hyrax::Ability

  # override user_groups method to use default institutional visibility for campus group access
  def user_groups
    user_grps = super
    user_grps.delete(Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED.to_s) if current_user.anonymous?
    user_grps
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    return unless admin?
    can [:manage], :all
  end

  def editor_permissions
    can [:read, :create, :update, :destroy], SolrDocument
    can [:read, :create, :edit, :update, :destroy, :file_manager], curation_concerns
    can [:read, :create, :edit, :update, :download, :destroy], FileSet
    can [:read, :create, :edit, :update, :destroy], Collection
    can [:read, :create, :edit, :update, :destroy], Authority
    can [:read, :create, :edit], CsvImportItem
  end

  def curator_permissions
    can [:read], curation_concerns
    can [:read, :download], FileSet
    can [:read], Collection
  end

  def campus_permissions
  end

  def anonymous_permissions
  end

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
