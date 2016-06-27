require 'colorize'

namespace :faker do
  
  namespace :generate do
    
    desc "Generate shares"
    task shares: :environment do
      
      puts ""
      puts "=== GENERATING FAKE SHARES ==="
      
      puts "Deleting all current shares"
      Share.delete_all
      
      (0..rand(100..300)).each do
        share = Share.new
        share.user = User.all.sample
        str = "#{share.user.name.yellow} shared the "
        if rand(5) == 0
          share.resource = Media::Playlist.all.sample
          str += "playlist #{share.resource.name.cyan}"
        else
          share.resource = Media::Song.all.sample
          str += "song #{share.resource.title.red}"
        end
        puts str
        share.save!
      end
    end
    
  end
  
  namespace :refresh do
    
    desc "Refresh share timestamps"
    task shares: :environment do
      puts "Refreshing share timestamps"
      Share.all.each do |x|
        x.created_at = Faker::Time.between(100.days.ago, DateTime.now)
        x.updated_at = x.created_at
        x.save
      end
    end
    
  end
  
end