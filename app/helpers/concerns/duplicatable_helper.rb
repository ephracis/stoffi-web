# frozen_string_literal: true
module Concerns
  # Helper methods for duplicates.
  module DuplicatableHelper
    def mark_as_duplicate_tag(resource, _options = {})
      link_to '#', class: :button, data: {
        button: true,
        duplicatable_url: url_for([resource, l: current_locale,
                                             action: :find_duplicates])
      } do
        content_tag :span, t('duplicatable.link')
      end
    end
  end
end
