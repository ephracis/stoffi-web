# Copyright (c) 2015 Simplare

module Media
  
  # An event where artists have performances.
  class Event < ActiveRecord::Base
    
    # concerns
    include Base
    include Sourceable
    include Imageable
    include Rankable
    include Duplicatable
  
    # associations
    has_and_belongs_to_many :artists, join_table: :performances
    has_many :listens, through: :artists
  
    # validations
    validates :name, :venue, :start, :longitude, :latitude, presence: true
    validates :longitude, :latitude, numericality: true
    validates :name, uniqueness: { scope: [ :start, :venue ] }
  
    acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude
  
    self.default_image = "gfx/icons/256/event.png"
  
    searchable do
      text :name, boost: 5
      text :content, :category
      string :locations, multiple: true do
        sources.map(&:name)
      end
      integer :archetype_id
    end
  
    # Find event by a hash specifying its attributes.
    #
    # If no matching event is found, `nil` is returned.
    def self.find_by_hash(hash)
    
      # look for same name, same city and same start date (within an hour)
      date = hash[:start]
      date = Date.parse(date) if date.is_a? String
      date = Time.now unless date
      d_upper = date + 1.hour
      d_lower = date - 1.hour
      event = where("lower(name) = ? and lower(venue) = ? and start between ? and ?",
        hash[:name].to_s.downcase, hash[:venue].to_s.downcase, d_lower, d_upper).first
      return event if event
      
      return nil
    end
  
    # Events that will occur in the future.
    def self.upcoming
      where(['start > ?', Time.now])
    end
  end
end