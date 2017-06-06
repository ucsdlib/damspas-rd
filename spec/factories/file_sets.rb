FactoryGirl.define do
  # The ::FileSet model is defined in spec/internal/app/models by the
  # hyrax:install generator.
  factory :file_set, class: FileSet do
    transient do
      user { FactoryGirl.create(:user) }
      content nil
    end

    after(:create) do |file, evaluator|
      if evaluator.content
        Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
      end
    end

    after(:build) do |file, evaluator|
      file.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :file_with_work do
      after(:build) do |file, _evaluator|
        file.title = ['testfile']
      end
      after(:create) do |file, evaluator|
        if evaluator.content
          Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
        end
        FactoryGirl.create(:public_object_resource, user: evaluator.user).members << file
      end
    end

    factory :suppress_discovery_file_set do
      after(:build) do |file, _evaluator|
        file.title = ['testfile']
        file.visibility = VisibilityService::VISIBILITY_TEXT_VALUE_SUPPRESS_DISCOVERY
      end
      after(:create) do |file, evaluator|
        if evaluator.content
          Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
        end
      end
    end

    factory :metadata_only_file_set do
      after(:build) do |file, _evaluator|
        file.title = ['testfile']
        file.visibility = VisibilityService::VISIBILITY_TEXT_VALUE_METADATA_ONLY
      end
      after(:create) do |file, evaluator|
        if evaluator.content
          Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
        end
      end
    end

    factory :culturally_sensitive_file_set do
      after(:build) do |file, _evaluator|
        file.title = ['testfile']
        file.visibility = VisibilityService::VISIBILITY_TEXT_VALUE_CULTURALLY_SENSITIVE
      end
      after(:create) do |file, evaluator|
        if evaluator.content
          Hydra::Works::UploadFileToFileSet.call(file, evaluator.content)
        end
      end
    end
  end
end
