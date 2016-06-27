# Copyright (c) 2015 Simplare

module Media
  
  # Describes an album, created by one or more artists, containing songs.
  # FIXME: rename `#title` to `#name`.
  class Album < ActiveRecord::Base
    
    # concerns
    include Base
    include Sourceable
    include Imageable
    include Rankable
    include Duplicatable
    include Sortable
    include FriendlyId
  
    # associations
    has_many :album_tracks
    has_many :songs, through: :album_tracks
    has_many :genres, through: :songs
    has_many :listens
    has_many :artists, -> { uniq }, through: :songs
    has_many :playlists, -> { uniq }, through: :songs
    
    # validations
    validates :title, presence: true
  
    # The sum of the normalised popularity of the album itself, and the normalised popularity
    # of all its songs.
    def popularity
      p = super
      p += songs.inject(p) { |sum,x| sum + x.popularity } if songs.count > 0 and p == 0
      p
    end
  
    # The name of the artists of the songs in the album.
    def artist_names
      artists.collect { |a| a.name }.to_sentence
    end
  
    # Find album with same title and set of artists.
    def self.find_by_hash(hash)
      artist_txt = hash[:artist]
      artist_txt = join_artists(hash[:artists]) if hash.key?(:artists)
      where('lower(title) = ?', hash[:title].downcase).each do |album|
        return album if join_artists(album.artists) == artist_txt
      end
      return nil
    end
    
    def self.create_by_hash(hash)
      hash.delete :artists
      super hash
    end
  
    # Paginates the songs of the album. Should be called before <tt>paginated_songs</tt> is called.
    #
    #   album.paginate_songs(10, 30)
    #   songs = album.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
    def paginate_songs(limit, offset)
      @paginated_songs = Array.new
      songs.limit(limit).offset(offset).each do |song|
        @paginated_songs << song
      end
    end
  
    # Returns a slice of the album's songs which was created by <tt>paginated_songs</tt>.
    #
    #   album.paginate_songs(10, 30)
    #   songs = album.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
    def paginated_songs
      return @paginated_songs
    end
    
    private
    
    # Create a string with all artists that will uniquely describe the
    # set of artists of the song.
    def self.join_artists(artists)
      artists.collect do |artist|
        name = artist
        name = artist.name if artist.is_a?(Media::Artist)
        name = artist[:name] if artist.is_a?(Hash)
        name.downcase.strip.gsub("\t", '')
      end.sort.join("\t")
    end
    
    # Configure all concerns and extensions.
    def self.configure_concerns
  
      # Searchable
      searchable do
        text :title, boost: 5
        text :artists do
          artists.map(&:name)
        end
        string :locations, multiple: true do
          sources.map(&:name)
        end
        integer :archetype_id
      end
  
      # Sortable
      can_sort :songs
      
      # Enable URLs like `/albums/:name`.
      friendly_id :title, use: :slugged
      
    end
    configure_concerns
  
  end
end
