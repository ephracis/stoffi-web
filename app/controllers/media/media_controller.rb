# Copyright (c) 2015 Simplare

module Media
  
  # An abstract controller for media controllers.
  #
  # This assumes that the controller follows a naming convention with the name
  # of a model class followed by the suffix 'Controller'.
  class MediaController < ApplicationController
    
    # allow only anonymous access to `#index` and `#show`.
    oauthenticate except: [ :index, :show ]
    
    # respond to both UI and API requests
    respond_to :html, :json
    
    # set resource instance for some methods
    before_action :set_resource, only: [ :show, :edit, :update, :destroy ]
    
    private
    
    # Attempt to create an instance of the resource given the parameters.
    def set_resource
      unless resource_klass.constantize.exists? params[:id]
        not_found(resource_klass.parameterize) and return
      end
      @resource = resource_klass.constantize.find(params[:id])
      instance_variable_set(:"@#{resource_klass.demodulize.parameterize}",
        @resource)
    rescue StandardError => e
      raise e if Rails.env.test?
    end
    
    # The name of the class of the resource for this controller.
    #
    # This assumes that the controller follows a naming convention.
    # For example MyModelController assumes that there is a model named MyModel.
    def resource_klass
      suffix = 'Controller'
      unless self.class.name.ends_with? suffix
        raise "Model doesn't following naming convention"
      end
      self.class.name.chomp(suffix).singularize
    end
    
    # Set the whitelist of parameters allowed when changing or creating a
    # resource.
    #
    # In most cases, this should be overridden by inhereting controllers.
    def resource_params
      params.require(resource_klass.demodulize.parameterize)
    end
    
    # Get the limit parameter for pagination.
    def limit
      params[:limit] || params[:l] || 10
    end
    
    # Get the offset parameter for pagination.
    def offset
      params[:offset] || params[:o] || 0
    end
    
    # Get the resource of the request.
    #
    # Note that some requests (for example `#index`) may not have a resource so
    # this will return `nil` in those cases.
    def resource
      instance_variable_get(:"@#{resource_klass.demodulize.parameterize}") ||
        @resource
    end
    
    # Assign an array of resources to an association of the current resource.
    #
    # The array of resources can be fetched from either the parameters or body
    # of the request.
    def associate_resources(association, options = {})
      return unless resource.present?
      
      association = association.to_s
      
      # default options
      options = {
        params: true, body: true
      }.merge(options)
      
      # verify that the association exists
      unless resource.class.reflections[association].present?
        raise "resource has no such association: #{association}"
      end
      
      # assign resources
      associate_resources_from_params(association) if options[:params]
      associate_resources_from_body(association) if options[:body]
    end
    
    private
    
    # Get the class object given an association name.
    #
    # For example, if the resource for the request is `Playlist` then
    # `association_class(:songs)` would return `Song`.
    def association_class(association)
      namespace = self.class.name.deconstantize
      namespace += '::' if namespace.present?
      klass = namespace + resource.class.reflections[association].class_name
      klass.constantize
    end
    
    # Assign an array of sourceable resources from the request's `params` to a
    # given association of the current resource.
    def associate_resources_from_params(association)
      return unless params.key?(association)
      associate_values association, params[association]
    end
    
    # Assign an array of sourceable resources from the request's `body` to a
    # given association of the current resource.
    def associate_resources_from_body(association)
      body = request.body.read
      return if body.blank?
      associate_values association, JSON.parse(body)
    rescue JSON::ParserError => e
      # do nothing
    rescue StandardError => e
      raise e if Rails.env.test?
    end
    
    # Assign an array of resources as associations to the resource of the
    # request.
    #
    # `values` can be either an array, or a hash of two array: `added` and
    # `removed`.
    #
    #  Each value representing the resource to be assigned can be either:
    # - The ID of the resource (either as `Integer` or `String`)
    # - A hash describing the resource
    # - A path to a source for the resource
    #
    # Examples:
    #
    #     # assuming that the resource of the request 
    #     # is of type `Media::Playlist`:
    #
    #     # by array
    #     associate_values :songs, [123, 456, { title: 'One Love' } ]
    #     
    #     # by hash
    #     associate_values :songs,
    #         added: [123, 456, { name: 'One Love' }],
    #         removed: ['stoffi:song:youtube:abc', 'stoffi:song:soundcloud:123']
    #
    def associate_values(association, values)
      values = { added: values } unless values.is_a?(Hash)
      if values.key? :added
        values[:added].each { |v| associate_value(association, v) }
      end
      if values.key? :removed
        values[:removed].each { |v| deassociate_value(association, v) }
      end
    end
    
    # Assign a single resource as an association to the resource of the
    # request.
    #
    # The value representing the resource to be assigned can be either:
    # - The ID of the resource (either as `Integer` or `String`)
    # - A hash describing the resource
    # - A path to a source for the resource
    #
    # Examples:
    #
    #     # assuming that the resource of the request 
    #     # is of type `Media::Playlist`:
    #
    #     # by ID 123
    #     associate_value :songs, 123
    #     
    #     # by hash with title 'One Love'
    #     associate_value :artists, { name: 'One Love' }
    #     
    #     # by path to youtube video with id 'abc'
    #     associate_value :songs, 'stoffi:song:youtube:abc'
    #
    def associate_value(association, value)
      r = get_resource_from_value association_class(association), value
      return unless r
      unless resource.send("#{association}").include?(r)
        resource.send("#{association}") << r
      end
    rescue StandardError => e
      raise e if Rails.env.test?
    end
    
    # Remove a single resource as an association to the resource of the
    # request.
    #
    # The value representing the resource to be assigned can be either:
    # - The ID of the resource (either as `Integer` or `String`)
    # - A hash describing the resource
    # - A path to a source for the resource
    #
    # Examples:
    #
    #     # assuming that the resource of the request 
    #     # is of type `Media::Playlist`:
    #
    #     # by ID 123
    #     deassociate_value :songs, 123
    #     
    #     # by hash with title 'One Love'
    #     deassociate_value :artists, { name: 'One Love' }
    #     
    #     # by path to youtube video with id 'abc'
    #     deassociate_value :songs, 'stoffi:song:youtube:abc'
    #
    def deassociate_value(association, value)
      r = get_resource_from_value association_class(association), value
      return unless r
      if resource.send("#{association}").include?(r)
        resource.send("#{association}").delete(r)
      end
    rescue StandardError => e
      raise e if Rails.env.test?
    end
    
    # Create a new resource of a given class given a value which is either:
    # - The ID of the resource (either as `Integer` or `String`)
    # - A hash describing the resource
    # - A path to a source for the resource
    def get_resource_from_value(klass, value)
      
      # ID
      if value.is_a?(Integer) or (value.is_a?(String) and value.to_i > 0)
        return klass.find(value.to_i) rescue nil
        
      # Hash
      elsif value.is_a?(Hash)
        unless klass.respond_to?(:find_or_create_by_hash)
          raise "Hash given but #{klass} is not sourceable"
        end
        return klass.find_or_create_by_hash(value) rescue nil
        
      # Path
      elsif value.is_a?(String)
        unless klass.respond_to?(:find_or_create_by_path)
          raise "Path given but #{klass} is not sourceable"
        end
        return klass.find_or_create_by_path(value) rescue nil
        
      # Unknown / unsupported
      else
        raise "Cannot create resource from value of type #{value.class.name}"
      end
    end
    
  end
  
end # module