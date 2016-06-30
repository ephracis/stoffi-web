# frozen_string_literal: true
require 'colorize'

namespace :faker do
  namespace :generate do
    desc 'Generate fake users'
    task users: :environment do
      puts ''
      puts '=== GENERATING FAKE USERS ==='

      puts 'Deleting all current users'
      User.delete_all

      # generate user with known credentials
      mail = 'test@mail.com'
      pass = 'secret'
      puts ''
      puts 'Generating admin with credentials:'
      puts "  Email: #{mail}"
      puts "  Password: #{pass}"
      puts ''
      pw = Digest::SHA256.hexdigest(mail + pass)
      User.create(
        email: mail,
        name: Faker::Name.name,
        slug: Faker::Internet.user_name,
        password: pw, password_confirmation: pw,
        admin: true
      )

      # generate new users
      (0..rand(100..300)).each do
        mail = Faker::Internet.email
        name = Faker::Name.name
        pass = SecureRandom.hex(30)
        puts "Generating user #{mail.yellow}"
        User.create(
          email: mail,
          password: pw, password_confirmation: pw,
          name: name,
          sign_in_count: rand(50),
          show_ads: rand(5) > 0
        )
      end
    end
  end

  namespace :refresh do
    desc 'Refresh user timestamps'
    task users: :environment do
      puts 'Refreshing user timestamps'
      User.all.each do |x|
        x.created_at = Faker::Time.between(100.days.ago, DateTime.current)

        if x.sign_in_count > 0
          x.updated_at = Faker::Time.between(x.created_at, DateTime.current)
          x.current_sign_in_at = Faker::Time.between(x.created_at, x.updated_at)

          if x.sign_in_count > 1
            x.last_sign_in_at = Faker::Time.between(
              x.created_at,
              x.current_sign_in_at
            )
          end
        end

        x.save
      end
    end
  end
end
