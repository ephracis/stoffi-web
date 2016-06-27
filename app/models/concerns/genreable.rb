# Copyright (c) 2015 Simplare

# Use this concern to make it possible to assign genres to a resource.
#
# This assumes that there is a model called `Media::Genre` with a `name`
# attribute.
#
# Assigning a genre or genres to a genreable resource is done by setting
# `#genre` to a string. For example:
#     song.genre = 'rock, pop, indie'
module Genreable
  extend ActiveSupport::Concern
  
  # Set the genre of the resource.
  #
  # `text` can be either a single genre, or a list of genres separated by comma.
  def genre=(text)
    genres.clear
    self.class.split_genre_text(text).each do |name|
      genres << Media::Genre.find_or_create_by(name: name)
    end
  end
  
  # Returns all genres as a sentence.
  def genre
    genres.map(&:name).sort.to_sentence
  end
  
  module ClassMethods
    
    def find_or_create_by_hash(hash)
      genres = create_from_string hash.delete(:genre)
      o = super(hash)
      genres.each { |g| o.genres << g unless o.genres.include?(g) }
      o
    end
    
    # Split a string describing the genre or genres into an array of genre names.
    def split_genre_text(text)
      text.to_s.split(',').map { |g| g.strip.capitalize }
    end
    
    # Split a string describing the genre or genres into an array of `Genre`s.
    def create_from_string(text)
      split_genre_text(text).map { |g| Media::Genre.find_or_create_by(name: g) }
    end
    
  end
end