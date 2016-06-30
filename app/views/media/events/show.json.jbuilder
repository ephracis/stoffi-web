# frozen_string_literal: true
json.extract! @event, :id, :name, :venue, :latitude, :longitude, :start, :stop,
              :content, :category, :created_at, :updated_at
