# frozen_string_literal: true
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
    include FriendlyId

    # associations
    has_and_belongs_to_many :artists, join_table: :performances
    has_many :listens, through: :artists

    # validations
    validates :name, :venue, :start, :longitude, :latitude, presence: true
    validates :longitude, :latitude, numericality: true
    validates :name, uniqueness: { scope: [:start, :venue] }

    acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

    # Find event by a hash specifying its attributes.
    #
    # If no matching event is found, `nil` is returned.
    def self.find_by_hash(hash)
      # look for same name, same city and same start date (within an hour)
      date = hash[:start]
      date = Date.parse(date) if date.is_a? String
      date = Time.current unless date
      d_upper = date + 1.hour
      d_lower = date - 1.hour
      event = find_by('lower(name) = ? and lower(venue) = ? and '\
                      'start between ? and ?',
                      hash[:name].to_s.downcase, hash[:venue].to_s.downcase,
                      d_lower, d_upper)
      return event if event

      nil
    end

    # Events that will occur in the future.
    def self.upcoming
      where(['start > ?', Time.current])
    end

    # Get an array of similar events.
    def similar(count = 5)
      r = []
      artists.each do |x|
        r.concat(x.events.where.not(id: id).offset(rand(x.events.count - 5))
                  .limit(count).to_a)
      end
      r.shuffle[0..count - 1]
    end

    private_class_method

    # Configure all concerns and extensions.
    def self.configure_concerns
      # Searchable
      searchable do
        text :name, boost: 5
        text :content, :category
        string :locations, multiple: true do
          sources.map(&:name)
        end
        integer :archetype_id
      end

      # Enable URLs like `/events/:name`.
      friendly_id :name, use: :slugged
    end
    configure_concerns
  end
end
