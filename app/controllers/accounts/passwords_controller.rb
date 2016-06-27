# Copyright (c) 2015 Simplare

module Accounts
  
  # Handle requests for resetting passwords.
  class PasswordsController < Devise::PasswordsController
    
    def edit
      u = User.find_by(reset_password_token: params[:reset_password_token])
      @email = u.email if u
      super
    end
  end
end