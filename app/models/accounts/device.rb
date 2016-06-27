# Copyright (c) 2015 Simplare

module Accounts

  # A device used to access the API.
  class Device < ActiveRecord::Base
    
    # concerns
    include Base
  
    # associations
    belongs_to :app
    belongs_to :user
    
    # validations
    validates :name, :app, :user, presence: true
    validates :name, uniqueness: { scope: [ :user, :app ] }
  
    # Whether or not the device is currently online.
    def online?
      status.to_s.downcase == "online"
    end
  
    # Updates the last access of the device.
    def poke(app, ip)
      self.app = app if app
      self.last_ip = ip if ip
      self.status = :online
      self.save
    end

    # The class of device.
    # Either: :laptop, :phone, :desktop or :tablet
    def type
      :laptop
    end
    
  end
end
