require 'colorize'

namespace :faker do
  namespace :generate do
  
	  desc "Generate fake albums"
    task albums: :environment do
      
      puts ""
      puts "=== GENERATING FAKE ALBUMS ==="
      
      puts "Deleting all current albums"
      Media::Album.delete_all
      
      filename = 'albums.txt'
      (0..rand(500..1000)).each do
        path = "#{Rails.root}/lib/assets/fakes/#{filename}"
        name = File.readlines(path).sample.strip
        puts "Generating album #{name.green}"
        Media::Album.create title: name
      end
    end
    
    namespace :associations do
      
      desc "Create random associations on albums"
      task albums: :environment do
      
        puts "Adding songs and artists to albums"
        Media::Album.all.each do |album|
          
          # deciding which artists should be in this album
          artists = []
          artists << Media::Artist.all.sample
          if rand(10) == 0
            artists << Media::Artist.all.sample
            artists << Media::Artist.all.sample if rand(10) == 0
          end
          artists.uniq!
          
          album.songs.clear
          (0..rand(3..15)).each do
            
            song = Media::Song.includes(:album_tracks).where(album_tracks: { song_id: nil }).sample
            break unless song
            unless album.songs.include? song
              puts "Adding #{song.title.red} to the album #{album.title.green}"
              album.songs << song
            end
            
            song.artists.clear
            puts "Adding #{artists.to_sentence.blue} to song #{song.title.red}"
            artists.each { |a| song.artists << a }
            
          end
          
        end
      end
      
    end
    
  end
end