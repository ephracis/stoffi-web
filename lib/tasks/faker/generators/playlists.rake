require 'colorize'

namespace :faker do
  
  namespace :generate do
  
	  desc "Generate fake playlists"
    task playlists: :environment do
      
      puts ""
      puts "=== GENERATING FAKE PLAYLISTS ==="
      
      puts "Deleting all current playlists"
      Media::Playlist.delete_all
      
      (0..rand(200..1000)).each do
        name = Faker::Lorem.words(rand(1..5), true)
        name = name.map(&:titleize) if rand(0..1) == 0
        name = name.join ' '
        puts "Generating playlist #{name.cyan}"
        Media::Playlist.create name: name, user: User.all.sample
      end
    end
    
    namespace :associations do
      
      desc "Create random associations on playlists"
      task playlists: :environment do
      
        puts "Adding songs and owners to playlists"
        Media::Playlist.all.each do |playlist|
          playlist.songs.clear
          (0..rand(3..30)).each do
            song = Media::Song.all.sample
            unless playlist.songs.include? song
              puts "Adding #{song.title.red} to the playlist #{playlist.name.cyan}"
              playlist.songs << song
            end
          end

          user = User.all.sample
          puts "Setting #{user.name.yellow} as the creator of the "+
            "playlist #{playlist.name.cyan}"
          playlist.user = user

          playlist.create_associate_activity playlist.user, playlist.songs
        end
      
      end
      
    end
    
  end
  
  namespace :refresh do
    
    desc "Refresh playlist timestamps"
    task playlists: :environment do
      puts "Refreshing playlist timestamps"
      Media::Playlist.all.each do |x|
        x.created_at = Faker::Time.between(100.days.ago, DateTime.now)
        x.updated_at = Faker::Time.between(x.created_at, DateTime.now)
        x.save
      end
    end
    
  end
  
end