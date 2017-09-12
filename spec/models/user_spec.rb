require 'rails_helper'
require 'spec_helper'

RSpec.describe User, type: :model do
  let(:included_modules) { described_class.included_modules }

  it 'has UserRoles functionality' do
    expect(included_modules).to include(::DamsUserRoles)
    expect(subject).to respond_to(:campus?)
  end

  it 'has Hydra Role Management behaviors' do
    expect(included_modules).to include(Hydra::RoleManagement::UserRoles)
    expect(subject).to respond_to(:admin?)
  end

  describe "#campus" do
    context "when access from campus" do
      subject do
        ip = '127.0.0.1'
        Rails.configuration.campus_ip_blocks << ip
        described_class.anonymous(ip)
      end

      it "is true" do
        expect(subject.campus?).to be_truthy
      end
    end
  end

  describe ".find_or_create_for_developer" do
    it "create a User for a new patron" do
      token = { 'info' => { 'email' => nil } }
      allow(token).to receive_messages(uid: 'test_user', provider: 'developer')
      user = User.find_or_create_for_developer(token)

      expect(user).to be_persisted
      expect(user.provider).to eq('developer')
      expect(user.uid).to eq('test_user')
    end

    it "reuse an existing User if the access token matches" do
      token = { 'info' => { 'email' => nil } }
      allow(token).to receive_messages(uid: 'test_user', provider: 'developer')
      User.find_or_create_for_developer(token)

      expect { User.find_or_create_for_developer(token) }.not_to change(User, :count)
    end
  end

  describe ".find_or_create_for_shibboleth" do
    before do
      @port = 1389

      @domain                 = "dc=example,dc=com"
      @toplevel_user_dn       = "cn=test_user,cn=TOPLEVEL,#{@domain}"
      @toplevel_user_password = "test_password"

      @regular_user_cn        = "regular_user"
      @regular_user_dn        = "cn=#{@regular_user_cn},ou=USERS,#{@domain}"
      @regular_user_password  = "regular_password"
      @regular_user_email     = "#{@regular_user_cn}@example.com"
      @group_ou = "ou=GROUPS,#{@domain}"
      @admin_group_cn = "admin_group"
      @curator_group_cn = "curator_group"

      @server = FakeLDAP::Server.new(port: @port)
      @server.run_tcpserver
      @server.add_user(@toplevel_user_dn, @toplevel_user_password)
      @server.add_user(@regular_user_dn, @regular_user_password, @regular_user_email)
      @server.add_to_group("cn=#{@admin_group_cn},ou=GROUPS,#{@domain}", @regular_user_dn)
      @server.add_to_group("cn=#{@curator_group_cn},ou=GROUPS,#{@domain}", @regular_user_dn)
      @client = Net::LDAP.new
      @client.port = @port
      @client.auth(@toplevel_user_dn, @toplevel_user_password)
    end

    after do
      @server.stop
    end

    it "create a User when a user is first authenticated" do
      User.create_ldap_connection(@client)
      token = { 'info' => { 'email' => nil } }
      allow(token).to receive_messages(uid: 'test_user', provider: 'shibboleth')

      user = User.find_or_create_for_shibboleth(token)

      expect(user).to be_persisted
      expect(user.provider).to eq('shibboleth')
      expect(user.uid).to eq('test_user')
    end
  end
end
