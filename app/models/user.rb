class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Curation Concerns behaviors.
  include CurationConcerns::User
  # Connects this user object to Sufia behaviors.
  include Sufia::User
  include Sufia::UserUsageStats

  # Connects this user object to user role behaviors.
  include ::DamsUserRoles

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.anonymous(ip)
    role = role_from_ip(ip)
    u = User.where(:email => role + '@anonymous').first || User.create(:email => role + '@anonymous')
    u.roles.clear << Role.find_or_create_by(name: role)
    u
  end

  def self.role_from_ip( ip )
    return Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED.to_s if campus_ip(ip)
    "public"
  end

  def self.campus_ip(ip)
    Rails.configuration.campus_ip_blocks.each do |block|
      if ip.start_with? block
        return true
      end
    end
    return false
  end
end
