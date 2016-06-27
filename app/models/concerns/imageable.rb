# Copyright (c) 2015 Simplare

module Imageable
  extend ActiveSupport::Concern
  
  included do
    has_many :images, as: :resource, dependent: :destroy
    class_attribute :default_image
    self.default_image = "http://placehold.it/438x255" # TODO: move to view
  end
  
  def image(size = :medium, options = {})
    options = {
      default: default_image
    }.merge(options)
    
    if size.is_a? Integer
      img = images.where(height: size, width: size).first
    elsif size.is_a? Symbol
      img = images.get_size(size) unless images.empty?
    else
      raise "Asked size is of invalid type: #{size}"
    end
    
    return img.url if img
    return options[:default]
  end
  
  def images_hash=(hash)
    return unless hash.key?(:images)
    imgs = Media::Image.new_by_hashes(hash[:images])
    
    imgs.each do |img|
      
      # no duplicates
      next unless images.where(url: img.url).empty?
      
      same_size = images.where(height: img.height, width: img.width)
      if same_size.empty?
        # create new image
        img.save
        images << img
      else
        # update url of existing
        same_size.each do |i|
          i.update_attribute :url, img.url
        end
      end
    end
  end
  
  module ClassMethods
    
    def find_or_create_by_hash(hash)
      o = super(hash)
      o.images << Media::Image.create_by_hashes(hash[:images]).reject { |i| o.images.include? i } if hash.key? :images
      o
    end
    
  end
end