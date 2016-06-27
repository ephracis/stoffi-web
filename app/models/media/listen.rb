# Copyright (c) 2015 Simplare

module Media
  
  # The act of a user to listen to a song.
  class Listen < ActiveRecord::Base
    
    # concerns
    include Base
    include PublicActivity::Model
  
    # associations
    belongs_to :user
    belongs_to :song
    belongs_to :device, class_name: Accounts::Device
    belongs_to :playlist
    belongs_to :album
    belongs_to :source
    has_many :link_backlogs, as: :resource, dependent: :destroy,
      class_name: Accounts::LinkBacklog
    
    # validations
    validates :user, :song, :device, presence: true

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
      song.to_s
    end
    
    # End the listening of a song.
    #
    # This will either update the `ended_at` timestamp or, if the listen was too
    # short, remove the listen instance from the database.
    def end
      raise 'Not implemented yet'
    end
    
    # Get the duration of the listen.
    def duration
      ended_at - created_at
    end
    
  end # class
end # module
