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
  
    # The image representing the device.
    def image(size = :huge)
      sizes = {
        tiny: 16,
        small: 32,
        medium: 64,
        large: 128,
        huge: 512
      }
      base = 'gfx/icons'
      size_folder = sizes[size]
      fname = 'device'
      fname += "_#{type.downcase}" if false
    
      "#{base}/#{size_folder}/#{fname}.png"
    end
  end
end