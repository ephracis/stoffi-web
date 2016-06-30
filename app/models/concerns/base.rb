# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# A set of basic stuff for all other resources, consumeable via the API are.
module Base
  extend ActiveSupport::Concern

  # What to print when cast to a string.
  def to_s
    return name if respond_to?(:name)
    return title if respond_to?(:title)
    super
  end
  alias display to_s

  # Use pretty URLs like `/artists/:name` or `/:username/:playlist`.

  # The path to use when creating links using `url_for` to the resource.
  # def to_param
  #  display.blank? ? id.to_s : "#{id}-#{to_s.parameterize}"
  # end
end
