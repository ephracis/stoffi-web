# Copyright (c) 2015 Simplare

# A share of a resource by a user.
class Share < ActiveRecord::Base
    
  # concerns
  include Base
  
  # associations
  belongs_to :resource, polymorphic: true
  belongs_to :user
  belongs_to :device
  has_many :link_backlogs, as: :resource, dependent: :destroy,
    class_name: Accounts::LinkBacklog
  
  # validations
  validates :resource, :user, presence: true
  
  # The string to display to users for representing the resource.
  def to_s
    resource.to_s
  end
  
end
