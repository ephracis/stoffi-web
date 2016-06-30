# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # A failed transmission of a resource (share/listen/etc) onto a third party
  # link.
  class LinkBacklog < ActiveRecord::Base
    belongs_to :link
    belongs_to :resource, polymorphic: true
    validates :link, :resource, presence: true
  end
end
