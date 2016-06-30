# frozen_string_literal: true
require 'colorize'

# TODO: clean up

namespace :faker do
  task generate: 'generate:all'
  namespace :generate do
    task associations: 'associations:all'
    task all: [:users, :apps, :devices, :artists, :albums, :songs, :genres,
               :events, :playlists, :sources, :images, :listens, :shares,
               :associations]
    namespace :associations do
      task all: [:songs, :albums, :events, :playlists]
    end
  end
  task refresh: 'refresh:all'
  namespace :refresh do
    task all: [:listens, :shares, :playlists, :users]
  end
end

task faker: ['db:reset', 'faker:generate', 'faker:refresh']
