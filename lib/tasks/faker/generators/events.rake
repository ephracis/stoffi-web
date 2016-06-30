# frozen_string_literal: true
require 'colorize'

namespace :faker do
  namespace :generate do
    desc 'Generate fake events'
    task events: :environment do
      puts ''
      puts '=== GENERATING FAKE EVENTS ==='

      puts 'Deleting all current events'
      Media::Event.delete_all

      (0..rand(50..200)).each do
        start = Faker::Time.between(100.days.ago, 100.days.from_now, :night)
        city = Faker::Address.city
        title = Faker::Lorem.words(rand(2..4), true).map(&:titleize).join(' ')

        puts "Generating event #{city.magenta} #{title.magenta}"
        Media::Event.create(
          name: "#{city} #{title}",
          venue: "#{Faker::Address.street_address}, #{city}",
          content: Faker::Lorem.sentences(rand(0..20)).join(' '),
          category: %w(festival concert).sample,
          start: start,
          stop: start + rand(1..5).days,
          longitude: Faker::Address.longitude,
          latitude: Faker::Address.latitude
        )
      end
    end

    namespace :associations do
      desc 'Create random associations on events'
      task events: :environment do
        puts 'Adding artists to events'
        Media::Event.all.each do |event|
          event.artists.clear
          (0..rand(5)).each do
            artist = Media::Artist.all.sample
            next if event.artists.include? artist
            puts "Adding #{artist.name.blue} "\
                 "to the event #{event.name.magenta}"
            event.artists << artist
          end
        end
      end
    end
  end
end
