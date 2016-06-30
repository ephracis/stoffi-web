# frozen_string_literal: true
require 'colorize'

namespace :faker do
  namespace :generate do
    desc 'Generate devices'
    task devices: :environment do
      puts ''
      puts '=== GENERATING FAKE DEVICES ==='

      puts 'Deleting all current devices'
      Accounts::Device.delete_all

      (0..rand(100..300)).each do
        name = Faker::Lorem.words(3).map(&:titleize).join(' ')
        puts "Generating device #{name.light_cyan}"

        Accounts::Device.create(
          app: App.all.sample,
          user: User.all.sample,
          name: name
        )
      end
    end
  end
end
