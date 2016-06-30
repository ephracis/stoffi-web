# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Models and controllers related to accounts such as sessions, accounts,
# unlocks, password resets, OAuth, etc.
#
# TODO: find a better name, since it clashes with the `Account` model.
module Accounts
  def self.use_relative_model_naming?
    true
  end
end
