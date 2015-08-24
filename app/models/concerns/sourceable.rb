# Copyright (c) 2015 Simplare

# All a resource to have several sources at external locations.
#
# A sourceable resource has many external sources. An external source
# is backed by a backend in the `Backends::Sources`. This backend can
# create the resource if it doesn't yet exist. This requires that the
# resource can be created or found using a hash.
module Sourceable
  extend ActiveSupport::Concern
  
  included do
    has_many :sources, as: :resource, dependent: :destroy
  end
  
  module ClassMethods
    
    # Find an existing, or create a new, resource from a hash.
    #
    # This call is recursive, meaning it will call the same method
    # in any associations that are in the hash.
    def find_or_create_by_hash(hash)
      return find_or_create_by_path(hash[:path]) if hash.key?(:path)
      
      hash = hash.deep_dup
      x = find_by_hash(hash)
      
      unless x
        x = create_by_hash(hash)
        
      else
        # assign associations (this is done in create_by_hash also)
        associations = extract_associations!(hash)
        x.assign_associations_from_hashes associations
      end
      
      x
    end
    
    # Find an existing resource from a hash.
    #
    # This method should be reimplemented by the models in most cases,
    # since this base version looks for a resource where all attributes
    # are identical to the values in the hash.
    def find_by_hash(hash)
      hash = hash.deep_dup
      extract_associations!(hash)
      find_by hash
    end
    
    # Create a new resource from a hash.
    #
    # This will create a new resource using the values inside the hash,
    # and also create any associations that the hash specifies if those
    # models respond to `find_or_create_by_hash`.
    #
    # Any keys in the hash that are not assignable attributes of the model
    # will be silently ignored.
    def create_by_hash(hash)
      hash = hash.deep_dup
      associations = extract_associations!(hash)
      remove_non_attributes!(hash)
      x = new.from_json(hash.to_json)
      x.save!
      x.assign_associations_from_hashes associations
      x
    end
    
    # Find an existing, or create a new, resource by a path identifying its source.
    def find_or_create_by_path(path)
      source = Media::Source.find_or_create_by_path(path)
      source.resource
    end
    
    private
    
    # Remove all keys which correspond to assocations from the hash and return them.
    #
    # For example, if the resource has an attribute `name` and a `belongs_to` attribute
    # named `owner` which has an attribute `name`, the following will happen:
    #
    #     hash = { name: 'foo', owner: { name: 'bar' } }
    #     assoc = extract_assocations! hash
    #     
    #     assoc # { owner: { name: 'bar' } }
    #     hash  # { name: 'foo' }
    def extract_associations!(hash)
      assoc = {}
      hash.reject! do |k,v|
        if reflections.key?(k.to_sym) or k.to_sym == :source
          assoc[k] = v
          true
        else
          false
        end
      end
      return assoc
    end
    
    # Removes all keys in the hash which do not correspond to assignable attributes.
    def remove_non_attributes!(hash)
      hash.select! do |k,v|
        new.respond_to? "#{k}="
      end
    end
    
  end # class methods
  
  # The sum of all normalized popularity from the resource's sources.
  def popularity
    sources.inject(0) { |sum,x| sum + x.normalized_popularity }
  end
  
  # The locations that the resource is sourced from.
  def locations
    sources.map(&:name).uniq.reject { |x| x.to_s.empty? }.sort
  end
    
  # Assign the `#sources` or `#source` associaton given a hash of the source.
  #
  # If the resource does not respond to this association an error is thrown.
  def assign_source_from_hash(value)
    
    # single source
    if respond_to?(:source)
      source = Media::Source.find_or_create_from_hash(value)
      
    # multiple sources
    elsif respond_to?(:sources)
      value = [value] unless value.is_a?(Array)
      value.each do |v|
        s = Media::Source.find_or_create_by_hash(v)
        sources << s unless sources.include?(s)
      end
      
    else
      raise 'Sourceable requires a #sources or #source association'
    end
  end
    
  # Assigns all associations from a hash of associations.
  #
  # If the association model does not respond to `find_or_create_by_hash` the association
  # will be silently ignored.
  def assign_associations_from_hashes(associations)
    associations.each do |key,values|
      if key == :source
        assign_source_from_hash(values)
      else
        values = [values] unless values.is_a? Array
        assign_association_from_hashes key, values
      end
    end
  end

  # Assign objects, created from an array of hashes, to an association.
  #
  # If the association model does not respond to `find_or_create_by_hash` the association
  # will be silently ignored.
  def assign_association_from_hashes(name, hashes)    
    hashes.each do |hash|
      # ensure hash is present and the association exists
      next unless hash.present? and self.class.reflections.key? name.to_sym
      
      # ensure the resource is sourceable
      reflection = self.class.reflections[name.to_sym]
      next unless reflection.klass.respond_to? :find_or_create_by_hash
      
      # create instance of resource
      r = reflection.klass.find_or_create_by_hash(hash)
      
      # associate instance
      if reflection.macro == :belongs_to
        send("#{name}=", r)
      else
        send(name) << r unless send(name).include?(r)
      end
    end
  end
  
  
end