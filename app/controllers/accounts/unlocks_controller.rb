# Copyright (c) 2015 Simplare

module Accounts
  
  # Handle requests for unlocking accounts.
  class UnlocksController < Devise::UnlocksController
    layout 'fullwidth'
  end
  
end