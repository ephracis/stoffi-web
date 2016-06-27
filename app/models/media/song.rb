# Copyright (c) 2015 Simplare

module Media
  
  # A song.
  # FIXME: rename `#title` to `#name`.
  class Song < ActiveRecord::Base
    
    # concerns
    include Base
    include Sourceable
    include Imageable
    include Genreable
    include Rankable
    include Duplicatable
    include FriendlyId

    # associations
    with_options uniq: true do |assoc|
      assoc.has_and_belongs_to_many :users
      assoc.has_and_belongs_to_many :playlists
      assoc.has_and_belongs_to_many :genres
    
      assoc.has_and_belongs_to_many :artists do
        def == (a)
          a = a.join(',') if a.is_a? Array
          Artist.uniq_name(self.join(',')) == Artist.uniq_name(a)
        end
      end
    end
    with_options as: :resource do |assoc|
      assoc.has_many :sources
      assoc.has_many :images
      assoc.has_many :shares
    end
    has_many :album_tracks
    has_many :albums, through: :album_tracks
    has_many :listens
    
    # validations
    validates :title, presence: true
  
    # The name of all the artists, as a sentence.
    def artist_names
      artists.collect { |a| a.name }.to_sentence
    end
  
    # Set the artists of the song, given their names.
    #
    # Attempts to intelligently split the artist name into several
    # artists. For example "Eminem feat. Dido" becomes [Eminem, Dido]
    def artists=(names)
      artists.clear
      Artist.split_name(names).each do |artist|
        artists << Artist.find_or_create_by(name: artist)
      end
    end
  
    # Get an array of similar songs.
    def similar(count = 5)
      s = []
    
      # collect associations
      genres.each { |x| s << x } if genres.count > 0
      albums.each { |x| s << x } if albums.count > 0
      artists.each { |x| s << x } if artists.count > 0
    
      # retrieve songs from associations
      r = []
      s.each do |x|
        r.concat x.songs.where.not(id: id).offset(rand(x.songs.count-5)).limit(count).to_a
      end
    
      # shuffle and return
      r.shuffle[0..count-1]
    end
    
    # Get the average length of all sources.
    def length
      lengths = sources.map(&:length)
      return 0 if lengths.empty?
      lengths.reduce(:+).to_f / lengths.size
    end
  
    # Extracts the title and artists from a string.
    #
    # For example:
    #
    # - "Stan by Eminem" => ["Eminem"], "Stan"
    # - "Eminem - Stan feat. Dido" => ["Eminem", "Dido"], "Stan"
    def self.parse_title(str)
      return [""], "" if str.blank?
    
      artists, title = split_title(str)
      title = clean_string(title)
      artists = artists.map { |x| clean_string(x) }
    
      return artists, title
    end
    
    # Find a song by title and set of artists.
    #
    # If the hash doesn't specify artist or artists, the first song with same
    # title will be returned.
    def self.find_by_hash(hash)
      artist_txt = hash[:artist]
      artist_txt = join_artists(hash[:artists]) if hash.key?(:artists)
      where('lower(title) = ?', hash[:title].downcase).each do |song|
        return song if artist_txt.blank? or join_artists(song.artists) == artist_txt
      end
      return nil
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
  
    # Split title and separate artist from song title.
    #
    # Examples:
    # - Eminem - Stan feat. Dido
    # - Eminem and Dido: Not Afraid
    # - Not Afraid, by Eminem & Dido
    # - Eminem "Not Afraid ft. Dido"
    #
    # All split to ['Eminem', 'Dido'], 'Not Afraid'
    def self.split_title(str)
      artists = []
      title = ''
      
      # split str into title and artist
      split = split_by_separator(str)
      split = split_by_quotes(str) unless split
      if split
        artists = [split[0]]
        title = split[1]
      end
      
      # extract artists from title string
      split = Artist.split_name title, split_by_words: false, sort: false
      title = split[0]
      artists << split[1..-1]
      
      # split artist string
      artists = artists.flatten.map do |a|
        Artist.split_name a
      end.flatten
      
      return [], str if title.blank?
      
      return artists, title
    end
    
    # Split titles into artist and song title by separators.
    #
    # Examples:
    # - Eminem - Not Afraid
    # - Eminem: Not Afraid
    # - Not Afraid, by Eminem
    def self.split_by_separator(str)
      separators = []
      ["-", ":", "~"].each {|s| separators.concat [" "+s, s+" ", " "+s+" "]}
      separators.map! { |s| [s, true] } # true means artist=left part
      separators << [", by ", false] # false mean artist=right part
      separators << [" by ", false]
      separators.each do |sep|
        next unless str.include? sep[0]
      
        s = str.split(sep[0], 2)
        artist = s[sep[1]?0:1].strip
        title = s[sep[1]?1:0].strip
        return artist, title
      end
      return nil
    end
    
    # Split title into artist and song title when song title is in quotes.
    #
    # Example:
    # - Eminem "Not Afraid"
    def self.split_by_quotes(str)
      t = "(\'(?<title>.+)\'|\"(?<title>.+)\")"
      a = "(?<artist>.+)"
      m = str.match("(#{t}\\s+#{a}|#{a}\\s+#{t})")
      return m[:artist], m[:title] if m
      return nil
    end
    
    # Clean up a song string.
    #
    # The following is removed:
    # - Meta phrases such as (Official video), [LYRICS], or (HD).
    # - Surrounding quotes, paranthesis, or other special characters.
    # - Double whitespace.
    def self.clean_string(str)
      
      # construct list of strings to remove.
      meta = [
        "official video", "lyrics", "with lyrics", "hq", "hd",
        "official", "official audio", "alternate official video"
      ]
      meta = meta.map { |x| ["\\("+x+"\\)","\\["+x+"\\]"] }.flatten
      meta << "official video"
      meta.each { |m| str = str.gsub(/#{m}/i, "") }
    
      # remove enclosings
      ["'.*'", "\".*\"", "\\(.*\\)", "\\[.*\\]"].each do |e|
        e = "/^#{e}$/"
        str = str[1..-2] if str.match(e)
      end
    
      # trim start and end
      chars = "-=_~\\s"
      str.gsub!(/\A[#{chars}]+|[#{chars}]+\Z/, "")
    
      # clean whitespace
      str.split.join(' ')
    end
    
    # Configure all concerns and extensions.
    def self.configure_concerns
  
      # Duplicatable
      include_associations_of_dups :listens, :shares, :genres
      find_duplicates_by :title
  
      # Searchable
      searchable do
        text :title, boost: 5
        text :artist_names
        integer :archetype_id
        string :locations, multiple: true do
          sources.map(&:name)
        end
      end
      
      # Enable URLs like `/artists/:name`.
      friendly_id :title, use: :slugged
      
    end
    configure_concerns
    
  end
end