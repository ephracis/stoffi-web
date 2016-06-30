# frozen_string_literal: true
require 'colorize'

namespace :faker do
  namespace :generate do
    desc 'Generate fake artists'
    task artists: :environment do
      puts ''
      puts '=== GENERATING FAKE ARTISTS ==='

      puts 'Deleting all current artists'
      Media::Artist.delete_all

      filename = 'artists.txt'
      (0..rand(100..300)).each do
        path = "#{Rails.root}/lib/assets/fakes/#{filename}"
        name = File.readlines(path).sample.strip
        puts "Generating artist #{name.blue}"
        Media::Artist.create name: name
      end
    end
  end
end
