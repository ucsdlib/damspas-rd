FactoryGirl.define do

  factory :object_resource, aliases: [:obj], class: ObjectResource do
    transient do
      user { FactoryGirl.create(:user) }
    end

    title ['Test title']
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    
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
  end
end
