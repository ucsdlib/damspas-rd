module Hyrax
  module PermissionBadgeOverride
    VISIBILITY_LABEL_CLASS = {
      authenticated: "label-info",
      embargo: "label-warning",
      lease: "label-warning",
      open: "label-success",
      restricted: "label-danger",
      suppress_discovery: "label-info",
      metadata_only: "label-danger",
      culturally_sensitive: "label-warning"
    }.freeze

    private

      def dom_label_class
        VISIBILITY_LABEL_CLASS.fetch(@visibility.to_sym)
      end
  end
end
