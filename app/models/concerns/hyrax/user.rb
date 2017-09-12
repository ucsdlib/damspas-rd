require 'oauth'

module Hyrax::User
  extend ActiveSupport::Concern

  included do
    # Adds acts_as_messageable for user mailboxes
    include Mailboxer::Models::Messageable
    # Connects this user object to Blacklight's Bookmarks and Folders.
    include Blacklight::User
    include Hydra::User
    include Hyrax::WithEvents
    delegate :can?, :cannot?, to: :ability

    # set this up as a messageable object
    acts_as_messageable

    # Set up proxy-related relationships
    has_many :proxy_deposit_requests, foreign_key: 'receiving_user_id'
    has_many :deposit_rights_given, foreign_key: 'grantor_id', class_name: 'ProxyDepositRights', dependent: :destroy
    has_many :can_receive_deposits_from, through: :deposit_rights_given, source: :grantee
    has_many :deposit_rights_received, foreign_key: 'grantee_id', class_name: 'ProxyDepositRights', dependent: :destroy
    has_many :can_make_deposits_for, through: :deposit_rights_received, source: :grantor

    scope :guests, ->() { where(guest: true) }
    scope :registered, ->() { where(guest: false) }
    scope :without_system_accounts, -> { where("#{Devise.authentication_keys.first} not in (?)", [::User.batch_user_key, ::User.audit_user_key]) }

    # Validate and normalize ORCIDs
    validates_with OrcidValidator
    after_validation :normalize_orcid

    # Set up user profile avatars
    mount_uploader :avatar, AvatarUploader, mount_on: :avatar_file_name
    validates_with AvatarValidator

    # Add token to authenticate Arkivo API calls
    after_initialize :set_arkivo_token, unless: :persisted? if Hyrax.config.arkivo_api?

    has_many :trophies
    has_one :sipity_agent, as: :proxy_for, dependent: :destroy, class_name: 'Sipity::Agent'

    attr_accessor :update_directory
  end

  # Look for, in order:
  #   A cached version of the agent
  #   A non-cached version (direct read of the database)
  #   A created version.
  #   A version created in another thread before we were able to create it
  def to_sipity_agent
    sipity_agent ||
      reload_sipity_agent ||
      begin
        create_sipity_agent!
      rescue ActiveRecord::RecordNotUnique
        reload_sipity_agent
      end
  end

  def profile_events(size = -1)
    event_store.for(stream[:event][:profile]).fetch(size)
  end

  def log_profile_event(event_id)
    event_store.for(stream[:event][:profile]).push(event_id)
  end

  def zotero_token
    self[:zotero_token].blank? ? nil : Marshal.load(self[:zotero_token])
  end

  def zotero_token=(value)
    self[:zotero_token] = if value.blank?
                            # Resetting the token
                            value
                          else
                            Marshal.dump(value)
                          end
  end

  def set_arkivo_token
    self.arkivo_token ||= token_algorithm
  end

  def token_algorithm
    loop do
      token = SecureRandom.base64(24)
      return token if User.find_by(arkivo_token: token).nil?
    end
  end

  # Coerce the ORCID into URL format
  def normalize_orcid
    # Skip normalization if:
    #   1. validation has already flagged the ORCID as invalid
    #   2. the orcid field is blank
    #   3. the orcid is already in its normalized form
    return if errors[:orcid].first.present? || orcid.blank? || orcid.starts_with?('http://orcid.org/')
    bare_orcid = Hyrax::OrcidValidator.match(orcid).string
    self.orcid = "http://orcid.org/#{bare_orcid}"
  end

  # Format the json for select2 which requires just an id and a field called text.
  # If we need an alternate format we should probably look at a json template gem
  def as_json(_opts = nil)
    { id: user_key, text: display_name ? "#{display_name} (#{user_key})" : user_key }
  end

  # Populate user instance with attributes from remote system (e.g., LDAP)
  # There is no default implementation -- override this in your application
  def populate_attributes; end

  def name
    display_name.titleize || raise
  rescue
    user_key
  end

  # Redefine this for more intuitive keys in Redis
  def to_param
    # Rails doesn't like periods in urls
    user_key.gsub(/\./, '-dot-')
  end

  # method needed for messaging
  def mailboxer_email(_obj = nil)
    nil
  end

  def ability
    @ability ||= ::Ability.new(self)
  end

  def all_user_activity(since = DateTime.current.to_i - 1.day)
    events = self.events.reverse.collect { |event| event if event[:timestamp].to_i > since }.compact
    profile_events = self.profile_events.reverse.collect { |event| event if event[:timestamp].to_i > since }.compact
    events.concat(profile_events).sort { |a, b| b[:timestamp].to_i <=> a[:timestamp].to_i }
  end

  module ClassMethods
    # Override this method if you aren't using email/password
    def audit_user
      User.find_by(email: audit_user_key) || User.create(email: audit_user_key)
    end

    def audit_user_key
      Hyrax.config.audit_user_key
    end

    # Override this method if you aren't using email/password
    def batch_user
      User.find_by(email: batch_user_key) || User.create(email: batch_user_key)
    end

    def batch_user_key
      Hyrax.config.batch_user_key
    end

    def find_or_create_system_user(user_key)
      User.find_by_user_key(user_key) || User.create!(Devise.authentication_keys.first => user_key, password: Devise.friendly_token[0, 20])
    end

    def from_url_component(component)
      User.find_by_user_key(component.gsub(/-dot-/, '.'))
    end

    def recent_users(start_date, end_date = nil)
      end_date ||= DateTime.current # doing or eq here so that if the user passes nil we still get now
      User.where(created_at: start_date..end_date)
    end
  end
end
