require 'colorize'

namespace :faker do
  namespace :generate do
  
	  desc "Generate genres"
    task genres: :environment do
      
      puts ""
      puts "=== GENERATING GENRES ==="
      
      puts "Deleting all current genres"
      Media::Genre.delete_all
      
      filename = 'genres.txt'
      (0..rand(50..200)).each do
        path = "#{Rails.root}/lib/assets/fakes/#{filename}"
        name = File.readlines(path).sample.strip
        puts "Generating genre #{name.light_black}"
        Media::Genre.create name: name
      end
    end
    
  end
end