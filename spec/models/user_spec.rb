require 'rails_helper'

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
    it "create a User when a user is first authenticated" do
      token = { 'info' => { 'email' => nil } }
      allow(token).to receive_messages(uid: 'test_user', provider: 'shibboleth')
      user = User.find_or_create_for_shibboleth(token)

      expect(user).to be_persisted
      expect(user.provider).to eq('shibboleth')
      expect(user.uid).to eq('test_user')
    end
  end
end
