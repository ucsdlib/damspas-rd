FactoryGirl.define do
  factory :admin_set do
    sequence(:title) { |n| ["Title #{n}"] }

    # Given the relationship between permission template and admin set, when
    # an admin set is created via a factory, I believe it is appropriate to go ahead and
    # create the corresponding permission template
    #
    # This way, we can go ahead
    after(:create) do |admin_set, evaluator|
      if evaluator.with_permission_template
        attributes = if evaluator.with_permission_template.respond_to?(:merge)
                       evaluator.with_permission_template.merge(attributes)
                     else
                       { admin_set_id: admin_set.id }
                     end
        # There is a unique constraint on permission_templates.admin_set_id; I don't want to
        # create a permission template if one already exists for this admin_set
        create(:permission_template, attributes) unless Hyrax::PermissionTemplate.find_by(admin_set_id: admin_set.id)
      end
    end

    transient do
      # false, true, or Hash with keys for permission_template
      with_permission_template false
    end
  end

  trait :public do
    read_groups ['public']
  end
end
