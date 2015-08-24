# Copyright (c) 2015 Simplare

module Media
  
  # A location of a resource at an external location.
  #
  # For example a song can have a Last.fm source and/or a Wikipedia source.
  class Source < ActiveRecord::Base
    
    # associations
    belongs_to :resource, polymorphic: true
  
    # validations
    validates :name, presence: true
    validates :foreign_id, presence: true, if: "foreign_url.blank?"
    validates :foreign_url, presence: true, if: "foreign_id.blank?"
    validates :foreign_url, uniqueness: true, if: "foreign_url.present?"

    # hooks
    after_save :reindex_resources
    before_destroy :reindex_resources

    # Force the resource of a path to be reindex by the search engine.
    def reindex_resources
      #Sunspot.index(resource) if resource
    end
    
    # Get an instance of the backend of the source.
    #
    # Examples:
    # - :youtube => Backends::Sources::Youtube
    # - :lastfm => Backends::Sources::Lastfm
    def backend
      unless @backend
        klass = "Backends::#{name.to_s.camelize}".constantize
        @backend = klass.new(resource_type, foreign_id)
      end
      @backend
    end
  
    # Get the path that identifies the source.
    def path
      case name
      when 'url' then foreign_url
      else "stoffi:#{resource_type.demodulize.underscore}:#{name}:#{foreign_id}"
      end
    end
  
    # Popularity normalized for the source type.
    #
    # For example, the resource with the highest popularity in the scope of the source type
    # gets 1.0.
    #
    # This makes it possible to compare the popularity between source types. The most popular
    # song on YouTube will thus compare equal to the most popular song on Jamendo.
    def normalized_popularity
      max = Source.where(name: name, resource_type: resource_type).maximum(:popularity) || 1
      (popularity || 0).to_f / max
    end
    
    # Get the resource of the source.
    #
    # If the resource is nil, it will be loaded by the backend if possible.
    def resource
      unless super
        r = load_resource
        update_attributes resource_id: r.id, resource_type: r.class.name
      end
      super
    end
  
    # A string representing the source, understandable by a human reader.
    def to_s
      case name.downcase
      when 'url' then 'URL'
      when 'lastfm' then 'Last.fm'
      when 'soundcloud' then 'SoundCloud'
      when 'youtube' then 'YouTube'
      else name.capitalize
      end
    end
    
    # Find an existing, or create a new, source from a path.
    #
    # The path should be either:
    # - A URL
    # - An identifier in the format `stoffi:TYPE:SOURCE:ID`.
    def self.find_or_create_by_path(path)
      find_or_create_by parse_path(path)
    end
    
    # Either find or create a source from a hash.
    def self.find_or_create_by_hash(hash)
      source = find_by_hash(hash)
      create_by_hash(hash) unless source
    end
    
    # Find an existing source from its name and either the foreign_url or
    # foreign_id.
    def self.find_by_hash(hash)
      keys = [:name]
      if hash.key? :foreign_url
        keys << :foreign_url
      else
        keys << :foreign_id
      end
      find_by hash.select { |k,v| k.to_sym.in?(keys) }
    end
    
    # Create a new source from a hash.
    def self.create_by_hash(hash)
      source = new.from_json(hash.to_json)
      source
    end
    
    private
    
    # Load the resource which the source is pointing to.
    #
    # This will also update this source object itself with the
    # new data in the hash returned from the backend.
    def load_resource
      # get the data from the backend
      hash = backend.generate_resource
      
      # update this source object with the data in the backend hash
      update_from_hash! hash
      
      # create the resource
      resource_class.find_or_create_by_hash hash
    end
    
    # Update the attributes of this `Source` by reading values from a hash.
    #
    # `hash` is most likely a hash returned from a backend when requesting
    # a specific resource.
    def update_from_hash!(hash)
      update_attributes hash.delete(:source)
    end
    
    # Get the class object of the resource type.
    def resource_class
      resource_type.constantize
    end
    
    # Parse a path and return a hash describing the path.
    def self.parse_path(path)
      if is_source_path? path
        parse_source_path path
      elsif is_url_path? path
        parse_url_path path
      else
        raise "Unsupported path: #{path}"
      end
    end
    
    # Parse a path which identifies a resource at an external source.
    #
    # The path should be in the format `stoffi:TYPE:SOURCE:ID`.
    def self.parse_source_path(path)
      splitted_path = path.split ':', 4
      {
        resource_type: "Media::#{splitted_path[1].camelize}",
        name: splitted_path[2].to_sym,
        foreign_id: splitted_path[3]
      }
    end
    
    # Parse a URL which points to a file.
    def self.parse_url_path(path)
      ext = File.extname(path)
      src = :url if is_url_path?(path)

      if ext.in? SONG_EXT or (ext.empty? and src == :url) # if no extension, assume song
        resource = 'Media::Song'
      elsif ext.in? PLAYLIST_EXT
        resource = 'Media::Playlist'
      else
        raise "Unsupported file extension: #{ext}"
      end

      {
        resource_type: resource,
        name: src,
        foreign_id: path,
      }
    end
    
    # Whether or not a path points to a resource at an external source.
    def self.is_source_path?(path)
      path.starts_with? 'stoffi:'
    end
    
    # Whether or not a path is a URL.
    def self.is_url_path?(path)
      path.start_with? 'http://' or path.start_with? 'https://'
    end
  
    # A list of all supported file extensions that identifies a song.
    SONG_EXT = ['.aac', '.ac3', '.aif', '.aiff', '.ape', '.apl', '.bwf', '.flac',
      '.m1a', '.m2a', '.m4a', '.mov', '.mp+', '.mp1', '.mp2', '.mp3', '.mp3pro',
      '.mp4', '.mpa', '.mpc', '.mpeg', '.mpg', '.mpp', '.mus', '.ofr', '.ofs', '.ogg',
      '.spx', '.tta', '.wav', '.wv']
  
    # A list of all supported file extensions that identifies a playlist.
    PLAYLIST_EXT = ['.b4s', '.m3u', '.pls', '.ram', '.wpl', '.asx', '.wax',
      '.wvx', '.m3u8', '.xspf', '.xml']
      
  end
end