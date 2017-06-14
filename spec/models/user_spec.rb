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
end
