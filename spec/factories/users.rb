FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'

    factory :admin do
      roles { [Role.where(name: 'admin').first_or_create] }
    end

    factory :editor do
      roles { [Role.where(name: 'editor').first_or_create] }
    end

    factory :curator do
      roles { [Role.where(name: 'curator').first_or_create] }
    end

    factory :campus do
      campus_role = Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      roles { [Role.where(name: campus_role).first_or_create] }
    end

    factory :anonymous do
      roles { [] }
    end
  end

  trait :guest do
    guest true
  end
end

class MockFile
  attr_accessor :to_s, :id

  def initialize(id, string)
    self.id = id
    self.to_s = string
  end
end
