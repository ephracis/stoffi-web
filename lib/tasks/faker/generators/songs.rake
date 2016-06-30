# frozen_string_literal: true
require 'colorize'

namespace :faker do
  namespace :generate do
    desc 'Generate fake songs'
    task songs: :environment do
      puts ''
      puts '=== GENERATING FAKE SONGS ==='

      puts 'Deleting all current songs'
      Media::Song.delete_all

      filename = 'songs.txt'
      (0..rand(1000..5000)).each do
        path = "#{Rails.root}/lib/assets/fakes/#{filename}"
        name = File.readlines(path).sample.strip
        puts "Generating song #{name.red}"
        Media::Song.create title: name
      end
    end

    namespace :associations do
      desc 'Create random associations on songs'
      task songs: :environment do
        puts 'Adding genres to songs'
        Media::Song.all.each do |song|
          song.genres.clear
          (0..rand(5)).each do
            genre = Media::Genre.all.sample
            unless song.genres.include? genre
              puts "Adding genre #{genre.name.light_black} to {song.title.red}"
              song.genres << genre
            end
          end
        end
      end
    end
  end
end
