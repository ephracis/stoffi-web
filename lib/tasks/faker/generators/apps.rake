require 'colorize'

namespace :faker do
  namespace :generate do
    
    desc "Generate apps"
    task apps: :environment do
      
      puts ""
      puts "=== GENERATING FAKE APPS ==="
      
      puts "Deleting all current apps"
      App.delete_all
      
      (0..rand(5..30)).each do
        name = Faker::App.name
        author = Faker::App.author
        puts "Generating app #{name.light_red} by #{author.yellow}"
        App.create(
          name: name,
          user: User.all.sample,
          website: Faker::Internet.url,
          author: author,
          author_url: Faker::Internet.url,
        )
      end
    end
    
  end
end