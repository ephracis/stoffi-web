# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # An image, associated to a resource via the `Imageable` concern.
  class Image < ActiveRecord::Base
    # associations
    belongs_to :resource, polymorphic: true

    # validations
    validates :url, presence: true, uniqueness: true
    validates :width, presence: true, numericality: true
    validates :height, presence: true, numericality: true

    # hooks
    before_validation :set_size

    # Create new or fetch existing images from an array of hashes.
    #
    # The hash should be in the format:
    #   { width: W, height: H, url: URL }
    #
    # The keys `width` and `height` are optional. If not present
    # they will be set by looking at the size of the image.
    def self.create_by_hashes(hashes)
      images = new_by_hashes(hashes)
      images.map(&:save)
      images
    end

    # Create new images from an array of hashes.
    #
    # The hash should be in the format:
    #   { width: W, height: H, url: URL }
    #
    # The keys `width` and `height` are optional. If not present
    # they will be set by looking at the size of the image.
    def self.new_by_hashes(hashes)
      images = []
      return images unless hashes.is_a? Array
      hashes.each do |hash|
        begin
          # Fill missing size attributes
          unless hash.key?(:width) && hash.key?(:height)
            size = FastImage.size(hash[:url])
            hash[:width] = size[0]
            hash[:height] = size[1]
          end
          images << Image.new(
            url: hash[:url],
            width: hash[:width].to_i,
            height: hash[:height].to_i
          )
        rescue StandardError
          false
        end
      end
      images
    end

    # Get a list of available sizes given an array of desired sizes.
    #
    # Desired sizes is a single value, or an array of, symbols:
    #   :tiny, :small, :medium, :large, :huge
    #
    # If none of the desired sizes exist, the first size matching
    # `default_sizes` is returned.
    def self.get_size(desired_sizes)
      desired_sizes = [desired_sizes] unless desired_sizes.is_a? Array
      available_sizes = {}

      all.find_each do |img|
        available_sizes[size(img.width, img.height)] = img
      end

      desired_sizes.each do |s|
        return available_sizes[s] if available_sizes.key? s
      end

      default_sizes.each do |s|
        return available_sizes[s] if available_sizes.key? s
      end

      nil
    end

    private_class_method

    # A list of default sizes to return.
    #
    # If a size is asked for, but not found, the first match in this list is
    # returned instead.
    def self.default_sizes
      [:medium, :large, :small, :huge, :tiny]
    end

    # Set the size of the image given its URL.
    def set_size
      return if width.present? && height.present?
      size = FastImage.size(url)
      self.width = size[0]
      self.height = size[1]
    end

    # Translate a width+height into a symbol size such as `:large` or `:tiny`.
    def self.size(width, height)
      s = width * height
      return :tiny if s <= 32 * 32
      return :small if s <= 64 * 64
      return :medium if s <= 128 * 128
      return :large if s <= 256 * 256
      :huge
    end
  end
end
