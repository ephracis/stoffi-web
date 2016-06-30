# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # The business logic for session of logged in users.
  class SessionsController < Devise::SessionsController
    def new
      if request.referer && ![
        user_session_url, user_registration_url,
        user_unlock_url, user_password_url
      ].index(request.referer)
        session['user_return_to'] = request.referer
      end
      super
    end
  end
end
