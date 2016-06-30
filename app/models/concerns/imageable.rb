# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Allow resources to have images associated with them.
module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :resource, dependent: :destroy
    class_attribute :default_image
    self.default_image = 'http://placehold.it/438x255' # TODO: move to view
  end

  def image(size = :medium, options = {})
    options = {
      default: default_image
    }.merge(options)

    if size.is_a? Integer
      img = images.find_by(height: size, width: size)
    elsif size.is_a? Symbol
      img = images.get_size(size) unless images.empty?
    else
      raise "Asked size is of invalid type: #{size}"
    end

    return img.url if img
    options[:default]
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

  # Static class methods.
  module ClassMethods
    def find_or_create_by_hash(hash)
      o = super(hash)
      if hash.key? :images
        o.images << Media::Image.create_by_hashes(hash[:images])
                                .reject { |i| o.images.include? i }
      end
      o
    end
  end
end
