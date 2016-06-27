require 'colorize'

namespace :faker do
  namespace :generate do
    
    desc "Generate fake images"
    task images: :environment do
      
      puts ""
      puts "=== GENERATING FAKE IMAGES ==="
      
      puts "Deleting all current images"
      Media::Image.delete_all
      
      [Media::Song, Media::Album, Media::Artist, Media::Event].each do |klass|
        
        puts "Generating images for #{klass.to_s.demodulize.tableize}"
        
        klass.all.each do |obj|
          (1..rand(0..3)).each do |n|
            w = rand(100..500)
            h = rand(50..300)
            obj.images << Media::Image.create(
              url: "http://placehold.it/#{w}x#{h}",
              width: w, height: h
            )
          end
        end
        
      end
      
    end
    
  end
end