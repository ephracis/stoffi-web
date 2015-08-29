# Copyright (c) 2015 Simplare

module Sortable
  extend ActiveSupport::Concern
  
  module ClassMethods
    
    # Enable sorting on `collection` whenever it is accessed.
    def can_sort(collection, options = {})
      collection = collection.to_s
      options[:join_model] ||= self.reflections[collection].options[:through]
      options[:attribute] ||= :position
    
      # create method for accessing the order collection
      define_method "ordered_#{collection}" do |*arguments|
        join_model = options[:join_model]
        send(collection).
          select("#{join_model}.#{options[:attribute]},#{collection}.*").
          order("#{join_model}.#{options[:attribute]}")
      end
    end
  end
  
  # sort the `collection` in the order given by `ids`.
  def sort(collection, ids, options = {})
    collection = collection.to_s
    return if send(collection).empty?
    
    options[:join_model] ||= self.class.reflections[collection].options[:through]
    options[:attribute] ||= :position
    options[:collection_key] ||= collection.to_s.singularize+'_id'
    
    join_models = send(options[:join_model]).order(:position)
    join_model_ids = join_models.map { |x| x.send(options[:collection_key]) }
    
    # filter out ids which are not a join_model
    ids.select! { |x| x.in? join_model_ids }
    
    # add missing IDs to end of ids
    ids.concat join_model_ids.reject { |x| x.in? ids }
    
    pos = 0
    ids.each do |id|
      begin
        join_model = join_models.find_by(options[:collection_key] => id)
        join_model.update_attribute(options[:attribute], pos)
        pos += 1
      rescue
        # noop
      end
    end
  end
  
end