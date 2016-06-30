# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # A list of songs.
  class Playlist < ActiveRecord::Base
    # concerns
    include Base
    include Rankable
    include Sourceable
    include Followable
    include Sortable
    include PublicActivity::Model
    include FriendlyId

    # associations
    has_many :playlists_songs
    has_many :songs, through: :playlists_songs do
      def page(limit = 25, offset = 0)
        all(limit: limit, offset: offset)
      end
    end

    has_many :listens
    has_many :artists, through: :songs
    # REFACTOR: rename `resource` to stay consistent.
    has_many :shares, as: :object
    belongs_to :user
    has_many :link_backlogs, as: :resource, dependent: :destroy,
                             class_name: Accounts::LinkBacklog

    # validations
    validates :name, presence: true
    validates :user, presence: true
    validates :name, uniqueness: { scope: :user_id, case_sensitive: false }
    validates :slug, uniqueness: { scope: :user_id }

    # Whether or not the playlist is a dynamic playlist (ie just a search
    # filter).
    def dynamic?
      filter.present?
    end

    # Whether or not this playlist is visible to a given user.
    def visible_to?(user)
      is_public || self.user == user || user.admin?
    end

    # Create an activity for adding songs to playlist.
    def create_associate_activity(user, songs)
      create_activity :add,
                      owner: user,
                      params: { songs: songs.compact.map(&:id) }
    end

    # Create an activity for removing songs from playlist.
    def create_deassociate_activity(user, songs)
      create_activity :remove,
                      owner: user,
                      params: { songs: songs.map(&:id) }
    end

    def regenerate_slug
      this.slug = nil
      save!
    rescue
      begin
        this.slug = "#{id}-#{to_s.parameterize}"
        save!
      rescue
        raise Playlist.where(slug: slug).inspect
      end
    end

    # Configure all concerns and extensions.
    def self.configure_concerns
      # Allow `User`s to follow `Playlist`s.
      followable_by User

      # Allow `Playlist#songs` to be sorted, access via `Playlist#sorted_songs`.
      can_sort :songs

      # Record activity on this resource.
      tracked owner: proc { |controller, model|
        return controller.current_user if controller && controller.current_user
        model.user
      }

      # Allow this resource to be searched for.
      searchable do
        text :name, boost: 5
        text :artists do
          artists.map(&:name)
        end
        text :songs do
          songs.map(&:title)
        end
        string :locations, multiple: true do
          sources.map(&:name)
        end

        # not duplicatable, but still need to index this field
        integer :archetype_id do
          0
        end
      end

      # Enable URLs like `/:username/:playlist`.
      friendly_id :name, use: :slugged
    end
    configure_concerns

    # Override so we can generate in case it's `nil`.
    def to_param
      save! if slug.blank?
      super
    end

    # TODO: set default scope to public or own.
  end
end
