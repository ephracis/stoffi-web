# frozen_string_literal: true
module DuplicatableController
  extend ActiveSupport::Concern

  # Static methods for the concern.
  module ClassMethods
    # Specify a class as duplicatable.
    #
    # This will cause the controller to automatically redirect show
    # requests for the model to its archetype, and allow update/create
    # requests to specify :archetype
    def can_duplicate(resource)
      @duplicatable_model = resource
      before_action :redirect_duplicates, only: :show
      before_action :parse_duplicate_params, only: [:update, :create]
    end

    def duplicatable_model
      @duplicatable_model
    end
  end

  def find_duplicates
    set_resource
    render partial: '/concerns/duplicatable/find', locals: {
      duplicatable_model: self.class.duplicatable_model.to_s.tableize,
      resource: resource
    }
  end

  def mark_duplicates
    set_resource
    klass = self.class.duplicatable_model.to_s.tableize.singularize.to_sym
    params[klass].each do |id|
      begin
        dup = self.class.duplicatable_model.find(id)
        dup.duplicate_of resource
      rescue
        1 + 2 # do nothing
      end
    end
    head :ok
  end

  private

  # Automatically redirect to a resource's archetype if it has one
  def redirect_duplicates
    return if params[:dedup] && current_user.admin?
    klass = self.class.duplicatable_model.unscoped
    klass = klass.friendly if klass.respond_to? :friendly
    resource = klass.find(params[:id])
    redirect_to(resource.archetype) && return if resource.duplicate?
  end

  # Look for :archetype in params and change it from an ID as string, to
  # a real object.
  def parse_duplicate_params
    resource_key = self.class.duplicatable_model.to_s.demodulize.parameterize
                       .to_sym
    if params.key?(resource_key) && params[resource_key].key?(:archetype)
      update_duplicate_params resource_key
    end
  end

  def update_duplicate_params(resource_key)
    id = params[resource_key][:archetype]

    if id.present?
      resource = self.class.duplicatable_model.unscoped.find(id)
      params[resource_key][:archetype_id] = resource.id
      params[resource_key][:archetype_type] = resource.class.name

    else # unmark as duplicate
      params[resource_key][:archetype_id] = nil
      params[resource_key][:archetype_type] = nil
    end

    params[resource_key].delete :archetype
  end
end
