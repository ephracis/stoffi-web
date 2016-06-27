require 'colorize'

namespace :faker do
  namespace :generate do
    
    desc "Generate listens"
    task listens: :environment do
      
      puts ""
      puts "=== GENERATING FAKE LISTENS ==="
      
      puts "Deleting all current listens"
      Media::Listen.delete_all
      
      (0..rand(200..3000)).each do
        listen = Media::Listen.new
        listen.user = User.all.sample
        listen.song = Media::Song.all.sample
        listen.ended_at = listen.created_at = DateTime.now
        listen.device = Accounts::Device.all.sample
        case rand(5)
        when 0, 1 then listen.playlist = Media::Playlist.all.sample
        when 2 then listen.album = Media::Album.all.sample
        end
        
        str = "#{listen.user.name.yellow} listened to "+
          "#{listen.song.title.red}"
        str += " from the album #{listen.album.title.green}" if listen.album
        str += " from the playlist #{listen.playlist.name.cyan}" if listen.playlist
        str += " at #{listen.created_at}"
        puts str
        listen.save
      end
    end
    
  end
    
  namespace :refresh do
    
    desc "Refresh listen timestamps"
    task listens: :environment do
      puts "Refreshing listen timestamps"
      Media::Listen.all.each do |x|
        x.created_at = Faker::Time.between(100.days.ago, DateTime.now)
        x.ended_at = x.created_at + rand(60..300).seconds
        x.updated_at = x.ended_at
        x.save
      end
    end
      
  end
  
end