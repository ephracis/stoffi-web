# Copyright (c) 2015 Simplare

module Rankable
  extend ActiveSupport::Concern
  
  module ClassMethods
  
    # Sort objects by association count.
    #
    # For example, `Song`s can be sorted by `Song.listens.count`.
    #
    # TODO: limit number of SQL queries and keep the whole thing as a relation.
    def top(options = {})
      options = {
        associations: [:listens, :popularity], limit: 10, offset: 0
      }.merge(options)
      
      # fetch all songs and the association count to sort on
      l = create_association_values options[:associations]
      
      # sort the array
      l = l.sort_by do |x|
        x[1]
      end.reverse
      
      # fetch the top objects
      l.map { |x| x[0] }[options[:offset]..options[:offset]+options[:limit]-1]
    end
    
    private
    
    # Create a hash where the each model is a key the value is a quantification
    # of the given associations.
    def create_association_values(associations)
      all.map do |r|
        [r, associations.map { |a| quantify_value(r.send(a)) }]
      end.to_h
    end
    
    # Return either the value (if it's already numerical) or it's count or
    # length (if it's a Relation or Array).
    def quantify_value(value)
      return value if value.is_a?(Integer) or value.is_a?(Float)
      return value.length if value.respond_to?(:length)
      raise "Cannot quantify #{value}"
    end
    
  end
end