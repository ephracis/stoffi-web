# Copyright (c) 2015 Simplare

module Media
  
  # A list of songs.
  class Playlist < ActiveRecord::Base
    
    # concerns
    include Base
    include Rankable
    include Sourceable
    include Followable
    include Sortable
  
    # associations
    has_many :playlists_songs
    has_many :songs, through: :playlists_songs do
      def page(limit=25, offset=0)
        all(limit: limit, offset: offset)
      end
    end
  
    has_many :listens, through: :songs
    has_many :artists, through: :songs
    has_many :shares, as: :object # REFACTOR: rename `resource` to stay consistent.
    belongs_to :user
    has_many :link_backlogs, as: :resource, dependent: :destroy, class: Accounts::LinkBacklog
  
    # validations
    validates :name, presence: true
    validates :user, presence: true
    validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
  
    followable_by User
    can_sort :songs
  
    searchable do
      text :name, boost: 5
      text :artists do
        artists.map(&:name)
      end
      text :songs do
        songs.map(&:title)
      end
      string :locations, multiple: true do
        sources.map(&:name)
      end
      integer :archetype_id do 0 end # not duplicatable, but still need to index this field
    end
  
    # The image of the playlist
    #
    # TODO: Move to Imageable and make it so it tries to find
    # an image based on name, genre, artist, album, song or let the
    # user set a custom image.
    def image(size = :huge)
      "gfx/icons/256/playlist.png"
      #songs.count == 0 ? "/assets/media/disc.png" : songs.first.picture
    end
  
    # TODO: create concern Paginateable.
    def paginate_songs(limit, offset)
      @paginated_songs = Array.new
      songs.limit(limit).offset(offset).each do |song|
        @paginated_songs << song
      end
    end
  
    # TODO: create concern Paginateable.
    def paginated_songs
      return @paginated_songs
    end
  
    # Whether or not the playlist is a dynamic playlist (ie just a search filter).
    def dynamic?
      filter.present?
    end
    
    # Whether or not this playlist is visible to a given user.
    def visible_to?(user)
      is_public or self.user == user or user.admin?
    end
    
    # TODO: set default scope to public or own?
    
  end
end