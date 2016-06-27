# Copyright (c) 2015 Simplare

# A share of a resource by a user.
class Share < ActiveRecord::Base
    
  # concerns
  include Base
  include PublicActivity::Model
  
  # associations
  belongs_to :resource, polymorphic: true
  belongs_to :user
  belongs_to :device
  has_many :link_backlogs, as: :resource, dependent: :destroy,
    class_name: Accounts::LinkBacklog
  
  # validations
  validates :resource, :user, presence: true

  # Record activity on this resource.
  tracked owner: Proc.new { |controller, model|
    if controller and controller.current_user
      return controller.current_user
    else
      model.user
    end
  }
  
  # The string to display to users for representing the resource.
  def to_s
    resource.to_s
  end
  
end
