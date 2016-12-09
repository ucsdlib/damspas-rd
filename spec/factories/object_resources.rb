FactoryGirl.define do
  factory :object_resource do
    title ["Test title"]
    rights_statement ["http://creativecommons.org/licenses/by/3.0/us/"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { FactoryGirl.create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    # https://github.com/projecthydra/hydra-head/blob/master/hydra-access-controls/app/models/concerns/hydra/access_controls/access_right.rb
    factory :campus_only_object_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end

    factory :private_object_resource do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    factory :object_resource_with_file do
      after(:create) do |object_resource, evaluator|
        file = FactoryGirl.create(:file_set, user: evaluator.user)
        object_resource.ordered_members << file
        object_resource.save
        file.update_index
      end
    end
  end
end
