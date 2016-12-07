module DamsUserRoles
  extend ActiveSupport::Concern

  def admin?
    roles.any? {|role| role.name == "admin"}
  end

  def editor?
    roles.any? {|role| role.name == "editor"}
  end

  def curator?
    roles.any? {|role| role.name == "curator"}
  end

  def campus?
    roles.any? {|role| role.name == Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED.to_s}
  end

  def anonymous?
    !persisted? && !campus? || !(admin? || editor? || curator? || campus?)
  end
end
