# Copyright (c) 2015 Simplare

module Media
  
  # A genre, (loosely) defining a musical style.
  class Genre < ActiveRecord::Base
    
    # concerns
    include Base
    include Sourceable
    include Imageable
    include Rankable
    include FriendlyId
  
    # associations
    has_and_belongs_to_many :songs, uniq: true
    with_options through: :songs do |assoc|
      assoc.has_many :artists
      assoc.has_many :albums
      assoc.has_many :listens
      assoc.has_many :playlists
    end
  
    # validations
    validates :name, presence: true, uniqueness: true
    
    private
    
    # Configure all concerns and extensions.
    def self.configure_concerns
  
      # Searchable
      searchable do
        text :name
        string :locations, multiple: true do
          sources.map(&:name)
        end
        integer :archetype_id do 0 end # not duplicatable, but still need to index this field
      end
    
      # Enable URLs like `/genres/:name`.
      friendly_id :name, use: :slugged
      
    end
    configure_concerns

  end
  
end
