FactoryGirl.define do

  factory :object_resource, aliases: [:obj], class: ObjectResource do
    title ["Test title"]
    rights_statement ["http://creativecommons.org/licenses/by/3.0/us/"]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { FactoryGirl.create(:user) }
    end
    
    after(:build) do |obj, evaluator|
      obj.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :public_object_resource, traits: [:public]

    trait :public do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
    
    factory :object_resource_with_one_file do
      before(:create) do |obj, evaluator|
        obj.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user, title: ['Fileset Child'])
      end
    end
    
    factory :object_resource_with_one_child do
      before(:create) do |obj, evaluator|
        obj.ordered_members << FactoryGirl.create(:object_resource, user: evaluator.user, title: ['Object Resource Child'])
      end
    end
    
    factory :object_resource_with_file_and_object do
      before(:create) do |obj, evaluator|
        obj.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user)
        obj.ordered_members << FactoryGirl.create(:object_resource, user: evaluator.user)
      end
    end

    factory :object_resource_with_files do
      before(:create) { |obj, evaluator| 2.times {obj.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user) } }
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
