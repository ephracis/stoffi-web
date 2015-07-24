# Copyright (c) 2015 Simplare

module Media
  
  # An artist, author of songs.
  class Artist < ActiveRecord::Base
    
    # concerns
    include Base
    include Sourceable
    include Imageable
    include Rankable
    include Duplicatable
  
    # associations
    with_options uniq: true do |assoc|
      assoc.has_and_belongs_to_many :albums
      assoc.has_and_belongs_to_many :songs
      assoc.has_and_belongs_to_many :events, join_table: :performances
    end
    has_many :genres, through: :songs
    has_many :listens, through: :songs
  
    # validations
    validates :name, presence: true, uniqueness: true
  
    include_associations_of_dups :listens
  
    searchable do
      text :name
      string :locations, multiple: true do
        sources.map(&:name)
      end
      integer :archetype_id
    end
  
    self.default_image = "gfx/icons/256/artist.png"
  
    # Paginates the songs of the artist. Should be called before <tt>paginated_songs</tt> is called.
    #
    #   artist.paginate_songs(10, 30)
    #   songs = artist.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
    def paginate_songs(limit, offset)
      @paginated_songs = Array.new
      songs.limit(limit).offset(offset).each do |song|
        @paginated_songs << song
      end
    end
  
    # Returns a slice of the artist's songs which was created by <tt>paginated_songs</tt>.
    #
    #   artist.paginate_songs(10, 30)
    #   songs = artist.paginated_songs # songs will now hold the songs 30-39 (starting from 0)
    def paginated_songs
      return @paginated_songs
    end
    
    # Find an artist by its hash.
    def self.find_by_hash(hash)
      where("lower(name)=?", hash[:name].downcase).first
    end
  
    # Split an artist name when it contains words like: and, feat, vs
    #
    # Examples:
    # - Eminem feat Dido
    # - Eminem ft. Dido
    # - Eminem featuring Dido
    # - Eminem & Dido
    # - Eminem vs Dido
    #
    # All result in `['Dido', 'Eminem']`
    #
    # Options:
    #
    # - `split_by_words`
    #
    #   If set to true, words such as `vs`, `and` and comma (`,`) will act as splitters.
    #
    # - `split_by_feat`
    #
    #   If set to true, string such as `feat`, `ft.` and `featuring` will act as splitters.
    def self.split_name(name, options = {})
      return [] if name.blank?
      
      # default options
      options = {
        split_by_words: true,
        split_by_feat: true
      }.merge(options)
      
      splitted = [name]
      splitted = splitted.map { |s| split_by_feat(s) }.flatten if options[:split_by_feat]
      splitted = splitted.map { |s| split_by_words(s) }.flatten if options[:split_by_words]
      splitted.sort
    end
  
    private
    
    # Split out artists names from a string by words such as `featuring` and `ft.`
    #
    # Examples:
    # - Eminem feat Dido
    # - Eminem ft. Dido
    # - Eminem featuring Dido
    def self.split_by_feat(str)
      str.split(/\s+(?:feat(?:uring|s)?|ft)(?:\s+|\.\s*)/i)
    end
    
    # Split out artists names from a string by words such as `with` and `and`.
    #
    # Examples:
    # - Eminem and Dido
    # - Eminem with Dido
    # - Eminem & Dido
    # - Eminem, Dido
    def self.split_by_words(str)
      words = ['with', 'and', 'och', 'med', 'und'] # TODO: more words?
      words = words.map { |x| "|#{x}\\s" }.join
      words = "vs[\\.\\s]" + words
      str.split(/(?:(?:\s+(?:#{words}))|\s*[,\+\&])\s*/i)
    end
    
  end
end