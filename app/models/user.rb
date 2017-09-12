require 'net/ldap'
require 'fakeldap'

class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Curation Concerns behaviors.
  include Hyrax::User
  # Connects this user object to Sufia behaviors.
  include Hyrax::UserUsageStats

  # Connects this user object to user role behaviors.
  include ::DamsUserRoles

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # devise :trackable
  devise :trackable, :omniauthable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.find_or_create_for_shibboleth(access_token, _signed_in_resource = nil)
    uid = access_token.uid
    email = access_token['info']['email'] || "#{uid}@ucsd.edu"
    provider = access_token.provider
    name = access_token['info']['name']
    u = User.find_by(uid: uid, provider: provider) || User.create(uid: uid, provider: provider, email: email, full_name: name)
    u.roles << Role.find_or_create_by(name: Rails.configuration.dams_user_roles[4]) if in_admin_group?(uid)
    u.roles << Role.find_or_create_by(name: Rails.configuration.dams_user_roles[2]) if in_curator_group?(uid)
    u
  end

  # dummy auth for developer environment
  def self.find_or_create_for_developer(access_token, _signed_in_resource = nil)
    uid = access_token.uid
    email = access_token['info']['email'] || "#{uid}@ucsd.edu"
    provider = access_token.provider
    name = access_token['info']['name']
    u = User.find_by(email: email) || User.create(uid: uid, provider: provider, email: email, full_name: name)
    u.roles << Role.find_or_create_by(name: 'admin') if name == 'developer'
    u
  end

  def self.in_admin_group?(uid)
    # return false unless uid != 'test_user'
    lookup_group(uid, ldap_admin_group) == uid ? true : false
  end

  def self.in_curator_group?(uid)
    lookup_group(uid, ldap_curator_group) == uid ? true : false
  end

  def self.lookup_group(search_param, ldap_group)
    result = ''
    ldap = ldap_connection # calling Hydra::LDAP.connection is not working, using local implementation instead.
    result_attrs = ['sAMAccountName']
    composite_filter = Net::LDAP::Filter.construct("(&(sAMAccountName=#{search_param})(objectcategory=user)(memberof=#{ldap_group}))")
    ldap.search(filter: composite_filter, attributes: result_attrs, return_result: false) do |item|
      result = item.sAMAccountName.first
    end

    ldap_response(ldap)
    result
  end

  def self.ldap_connection
    @ldap_conn ||= Net::LDAP.new(ldap_connection_config)
  end

  def self.create_ldap_connection(conn)
    @ldap_conn = conn
  end

  def self.ldap_connection_config
    return @ldap_connection_config if @ldap_connection_config
    @ldap_connection_config = {}
    yml = ldap_config
    @ldap_connection_config[:host] = yml[:host]
    @ldap_connection_config[:port] = yml['port']
    @ldap_connection_config[:encryption] = { method: :simple_tls }
    if yml['username'] && yml['password']
      @ldap_connection_config[:auth] = { method: :simple }
      @ldap_connection_config[:auth][:username] = yml['username']
      @ldap_connection_config[:auth][:password] = yml['password']
      @ldap_connection_config[:base] = yml['base']
    end
    @ldap_connection_config
  end

  def self.ldap_config
    root = Rails.root || '.'
    env = Rails.env || 'test'
    @ldap_config ||= YAML.safe_load(ERB.new(IO.read(File.join(root, 'config', 'hydra-ldap.yml'))).result)[env].with_indifferent_access
  end

  def self.ldap_admin_group
    yml = ldap_config
    yml['admin_group']
  end

  def self.ldap_curator_group
    yml = ldap_config
    yml['curator_group']
  end

  def self.ldap_response(ldap)
    msg = "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"

    raise msg unless Rails.env.test? || ldap.get_operation_result.code.zero?
  end

  def self.anonymous(ip)
    role = role_from_ip(ip)
    u = User.find_by(email: role + '@anonymous') || User.create(email: role + '@anonymous')
    u.roles.clear << Role.find_or_create_by(name: role)
    u
  end

  def self.role_from_ip(ip)
    return Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED.to_s if campus_ip(ip)
    "public"
  end

  def self.campus_ip(ip)
    Rails.configuration.campus_ip_blocks.each do |block|
      return true if ip.start_with? block
    end
    false
  end
end
