FactoryGirl.define do
  factory :object_resource, aliases: [:obj], class: ObjectResource do
    title ["Test title"]
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
        component = FactoryGirl.create(:object_resource, user: evaluator.user, title: ['Object Resource Child'])
        obj.ordered_members << component
      end
    end

    factory :object_resource_with_file_and_object do
      before(:create) do |obj, evaluator|
        obj.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user)
        obj.ordered_members << FactoryGirl.create(:object_resource, user: evaluator.user)
      end
    end

    factory :object_resource_with_files do
      before(:create) do |obj, evaluator|
        2.times { obj.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user) }
      end
    end

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

    factory :with_embargo_date do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      transient do
        embargo_date { Date.tomorrow.to_s }
        current_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
        future_state { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      end
      factory :embargoed_object_resource do
        after(:build) do |work, evaluator|
          work.apply_embargo(evaluator.embargo_date, evaluator.current_state, evaluator.future_state)
        end
      end
      factory :embargoed_object_resource_with_files do
        after(:build) do |work, evaluator|
          work.apply_embargo(evaluator.embargo_date, evaluator.current_state, evaluator.future_state)
        end
        after(:create) do |work, evaluator|
          2.times { work.ordered_members << FactoryGirl.create(:file_set, user: evaluator.user) }
        end
      end
    end

    factory :suppress_discovery_object_resource_with_files do
      visibility VisibilityService::VISIBILITY_TEXT_VALUE_SUPPRESS_DISCOVERY
      before(:create) do |obj, evaluator|
        2.times { obj.ordered_members << FactoryGirl.create(:suppress_discovery_file_set, user: evaluator.user) }
      end
    end

    factory :metadata_only_object_resource_with_files do
      visibility VisibilityService::VISIBILITY_TEXT_VALUE_METADATA_ONLY
      before(:create) do |obj, evaluator|
        2.times { obj.ordered_members << FactoryGirl.create(:metadata_only_file_set, user: evaluator.user) }
      end
    end

    factory :culturally_sensitive_object_resource_with_files do
      visibility VisibilityService::VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE
      before(:create) do |obj, evaluator|
        2.times { obj.ordered_members << FactoryGirl.create(:culturally_sensitive_file_set, user: evaluator.user) }
      end
    end

    factory :object_with_image_file do
      after(:create) do |object_resource, evaluator|
        file_path = Rails.root.join("spec", "fixtures", "files", "file_1.jpg")
        file = FactoryGirl.create(:file_set, user: evaluator.user, content: File.open(file_path))
        object_resource.ordered_members << file
        object_resource.representative_id = file.id
        object_resource.save
      end
    end
  end
end
